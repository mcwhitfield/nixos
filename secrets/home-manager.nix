{
  self,
  config,
  domain,
  agenix,
  ...
}: let
  inherit (builtins) baseNameOf filter readFile listToAttrs;
  inherit (self.lib) mkOption types;
  inherit (self.lib.attrsets) attrByPath filterAttrs genAttrs' mapAttrs mapKeys nameValuePair;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) hasSuffix;
  inherit (self.lib.trivial) pipe;

  configKey = [domain "secrets"];
  cfg = attrByPath configKey {} config;
in {
  imports = [agenix.homeManagerModules.default];

  options.${domain} = {
    pubKeys = mkOption {
      type = types.attrsOf types.str;
      description = "Registered public keys in the domain.";
      readOnly = true;
      default = pipe ./. [
        listFilesRecursive
        (map toString)
        (filter (hasSuffix ".pub"))
        (genAttrs' readFile)
        (mapKeys baseNameOf)
      ];
    };
    secrets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          file = mkOption {
            type = types.path;
            description = "Path to the age-encrypted secret.";
          };
          owner = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              The user that will own the secret. Null value means the secret will not be mounted.
            '';
          };
          group = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The group that will own the secret. Defaults to `owner`.";
          };
          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "The chmod of the secret.";
          };
        };
      });
    };
  };

  config = {
    ${domain}.secrets = pipe ./. [
      listFilesRecursive
      (filter (f: !(hasSuffix ".nix" f)))
      (filter (f: !(hasSuffix ".pub" f)))
      (map (file: nameValuePair (baseNameOf file) {inherit file;}))
      listToAttrs
    ];

    age.secrets = pipe cfg [
      (filterAttrs (_: conf: conf.owner != null))
      (mapAttrs (_: conf:
        if conf.group != null
        then conf
        else conf // {group = conf.owner;}))
    ];
  };
}
