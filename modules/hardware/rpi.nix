{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (builtins) filter listToAttrs;
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) removePrefix;
  configKey = [domain "rpi"];
  cfg = attrByPath configKey {} config;
  firmwareRelease = pkgs.fetchzip {
    url = "https://github.com/pftf/RPi4/releases/download/v1.35/RPi4_UEFI_Firmware_v1.35.zip";
    hash = "sha256-/eeCXVayEfkk0d5OR743djzRgRnCU1I5nJrdUoGmfUk=";
    stripRoot = false;
  };
  firmwareFiles = self.lib.pipe firmwareRelease [
    listFilesRecursive
    (filter (p: (toString p) != "${firmwareRelease}/Readme.md"))
    (map (p: {
      name = removePrefix "${firmwareRelease}/" (builtins.unsafeDiscardStringContext p);
      value = p;
    }))
    listToAttrs
  ];
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Common configuration for Raspberry Pi cluster nodes.
      '';
    };
    cluster = mkOption {
      type = types.int;
      description = "Cluster ID of the RPI host.";
    };
    node = mkOption {
      type = types.int;
      description = "Node ID of the RPI within its cluster.";
    };
  };

  config = mkIf (cfg.enable) {
    nixpkgs.hostPlatform = "aarch64-linux";

    ${domain} = {
      network.nat.externalInterface = "enabcm6e4ei0";
    };

    boot = {
      # Load UEFI firmware to support systemd-boot.
      loader.systemd-boot.extraFiles = firmwareFiles;
      initrd = {
        availableKernelModules = ["uas" "xhci_pci"];
        kernelModules = ["broadcom" "genet"];
      };
    };
  };
}
