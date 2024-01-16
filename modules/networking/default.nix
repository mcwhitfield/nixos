{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Configure a standard networking setup for hosts on ${domain}.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    networking.domain = domain;
  };
}
