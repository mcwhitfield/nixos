{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "rpi"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Common configuration for Raspberry Pi cluster nodes.
    '';
    cluster = mkOption {
      type = types.int;
      description = "Cluster ID of the RPI host.";
    };
    node = mkOption {
      type = types.int;
      description = "Node ID of the RPI within its cluster.";
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];
    networking = {
      hostName = "rpi-${toString cfg.cluster}-${toString cfg.node}";
      networkmanager.enable = false;
    };
    nixpkgs = {
      hostPlatform = "aarch64-linux";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "usbhid"
          "usb_storage"
          "vc4"
          "pcie_brcmstb"
          "reset-raspberrypi"
        ];
        network = {
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            authorizedKeys = [config.${domain}.pubKeys."ssh-user-mark-ed25519.pub"];
          };
        };
      };
    };

    ${domain} = {
      disko.enable = true;
      persist.enable = true;
    };
  };
}
