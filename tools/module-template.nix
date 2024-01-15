{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain]; # TODO: Unique config subkey.
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        REPLACEME
      '';
    }; # TODO: Module description.
  };

  config = mkIf (cfg.enable) {
    # TODO: Module configs.
  };
}
