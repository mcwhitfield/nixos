{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "users"];
  cfg = attrByPath configKey {} config;
in {
  options =
    setAttrByPath configKey
    mkOption {
      type = types.attrsOf types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Enable the specified user on this system.
            '';
          };
        };
      };
      default = {};
      example = {mark.enable = true;};
      description = ''
        Configure the set of available users on this system.
      '';
    };

  config = mkIf (cfg != {}) {
    # TODO: Module configs.
  };
}
