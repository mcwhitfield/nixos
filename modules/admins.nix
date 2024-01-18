{
  self,
  domain,
  options,
  config,
  ...
}: let
  inherit (builtins) attrNames attrValues concatMap map readFile zipAttrsWith;
  inherit (self.lib) mkOption types zipListsWith;
  inherit (self.lib.attrsets) attrByPath catAttrs filterAttrs genAttrs setAttrByPath;

  configKey = [domain "admins"];
  cfg = attrByPath configKey {} config;

  mergeLikeUserSubmodule = loc: defs: let
    files = catAttrs "file" defs;
    vals = catAttrs "value" defs;
    userOpts = options.users.users.type.getSubOptions [];
    userMerge = opt: vals': let
      loc' = loc ++ [opt];
      defs' = zipListsWith (file: value: {inherit file value;}) files vals';
    in
      userOpts.${opt}.type.merge loc' defs';
  in
    zipAttrsWith userMerge vals;
in {
  options = setAttrByPath configKey {
    admins = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: let
        userCfg = config.users.users.${name};
      in {
        options = {
          emails = mkOption {
            type = types.str;
            description = ''
              A list of email addresses serving as an identifier for this administrator.
            '';
            default = userCfg.openssh.authorizedPrincipals;
            readOnly = true;
          };
          publicKeys = mkOption {
            type = types.submodule {
              options = {
                paths = mkOption {
                  type = types.listOf types.path;
                  description = "Store paths of the admin's public keys.";
                  readOnly = true;
                  default = userCfg.openssh.authorizedKeys.keyFiles;
                };
                texts = mkOption {
                  type = types.listOf types.str;
                  description = "Text content of the admin's public keys.";
                  readOnly = true;
                  default = map readFile cfg.admins.${name}.publicKeys.paths;
                };
              };
            };
            description = "SSH public keys identified with this administrator.";
            readOnly = true;
            default = {};
          };
        };
      }));
      description = ''
        The set of users granted administrative privileges over the ${domain} domain.
      '';
      readOnly = true;
      default = {
        mark = {};
      };
    };
    publicKeys = let
      adminPubkeys = catAttrs "publicKeys" (attrValues cfg.admins);
    in {
      paths = mkOption {
        type = types.listOf types.path;
        description = ''
          The store paths of all admin public keys for the system.
        '';
        readOnly = true;
        default = concatMap (pks: pks.paths) adminPubkeys;
      };
      texts = mkOption {
        type = types.listOf types.str;
        description = ''
          The text content of all admin public keys for the system.
        '';
        readOnly = true;
        default = concatMap (pks: pks.texts) adminPubkeys;
      };
    };
    users = mkOption {
      type = options.users.users.type;
      description = ''
        An alias for the subset of config.users containing only admins.
      '';
      readOnly = true;
      # Why on Earth do I need to discard context here, Nix? The "mark" in config.users.users and in
      # cfg.admins are both defined with plain (unquoted) string literals. Why is the ? operator
      # returning false for identical strings based (silently) on some hidden context I didn't even
      # define? `==` even returns true.
      default =
        filterAttrs (user: _: cfg.admins ? ${builtins.unsafeDiscardStringContext user})
        config.users.users;
    };
    extraSettings = mkOption {
      type = types.attrs // {merge = mergeLikeUserSubmodule;};
      description = ''
        Same options as config.users.users.<name>, but with definitions applied to all admin users.
      '';
      default = {};
    };
  };

  config.${domain}.admins.extraSettings.extraGroups = ["wheel"];
  config.users.users = genAttrs (attrNames cfg.admins) (_: cfg.extraSettings);
}
