{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "hardware" "nixos-container"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable common configuration for NixOS native containers.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    boot.isContainer = true;
    networking.useHostResolvConf = self.lib.mkForce false;
    ${domain} = {
      disko.enable = false;
      networking.resolved.enable = true;
      persist.mounts.system = "${config.${domain}.persist.mounts.root}/containers/${config.networking.hostName}";
    };
  };
}
