{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "networkmanager"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable NetworkManager for the system.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.persist.directories = ["/etc/NetworkManager/system-connections"];
    networking.networkmanager.enable = true;
  };
}
