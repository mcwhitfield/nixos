{
  self,
  domain,
  ...
}: let
  inherit (builtins) attrValues map readFile;
  inherit (self.lib) mkOption pipe types;
  inherit (self.lib.attrsets) filterAttrs setAttrByPath;
  inherit (self.lib.strings) hasPrefix hasSuffix;

  configKey = [domain "admins"];

  pubKeysOf = user: rec {
    paths = pipe self.secrets [
      (filterAttrs (s: _: hasPrefix "ssh-user-${user}" s))
      (filterAttrs (s: _: hasSuffix ".pub" s))
      attrValues
    ];
    names = map readFile paths;
  };
in {
  options = setAttrByPath configKey (mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        email = mkOption {
          type = types.str;
          description = "An email address serving as an identifier for this administrator.";
        };
        publicKeys = mkOption {
          type = types.listOf types.str;
          description = "SSH public keys identified with this administrator.";
        };
      };
    });
    description = ''
      The set of users granted administrative privileges over the ${domain} domain.
    '';
    readOnly = true;
    default = {
      mark = {
        email = "mark@${domain}";
        publicKeys = pubKeysOf "mark";
      };
    };
  });
}
