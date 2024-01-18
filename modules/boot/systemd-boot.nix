{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "boot" "systemd-boot"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = !config.boot.isContainer;
      description = ''
        Enable systemd-boot as the system bootloader.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.enable = false;
      systemd-boot = {
        enable = true;
        configurationLimit = 25;
      };
    };
  };
}
