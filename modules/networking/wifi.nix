{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "wifi"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Wi-fi configuration & support via NetworkManager.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain} = {
      admins.extraSettings.extraGroups = ["networkmanager"];
      persist.directories = ["/etc/NetworkManager/system-connections"];
    };
    environment.systemPackages = [pkgs.wirelesstools];
    networking.networkmanager.enable = true;
  };
}
