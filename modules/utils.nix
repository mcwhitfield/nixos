{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "utils"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Minor utilities for system management etc.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    boot.initrd.systemd.initrdBin = [pkgs.busybox];
    environment.systemPackages = with pkgs; [
      busybox
      lshw
    ];
  };
}
