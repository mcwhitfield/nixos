{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (builtins) filter listToAttrs;
  inherit (self.lib) mkEnableOption mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
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
      kernelModules = ["hns3"];
      loader = {
        efi.canTouchEfiVariables = true;
        generic-extlinux-compatible.enable = false;
        systemd-boot = {
          enable = true;
          extraFiles = firmwareFiles;
        };
      };
      initrd = {
        availableKernelModules = [
          "uas"
          "xhci_pci"
        ];
        kernelModules = ["hns3"];
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
