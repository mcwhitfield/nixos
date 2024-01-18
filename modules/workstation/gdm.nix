{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "workstation" "gdm"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configure a workstation with a GNOME Display Manager.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    services.xserver.displayManager.gdm = {
      enable = true;
      banner = config.networking.fqdn;
    };
  };
}
