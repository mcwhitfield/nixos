{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "hardware" "framework-12"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Common configuration for Framework 12 laptop hardware support.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    boot = {
      binfmt.emulatedSystems = ["aarch64-linux"];
      initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["kvm-intel"];
      # https://community.frame.work/t/solved-guide-12th-gen-not-sending-xf86monbrightnessup-down/20605
      extraModprobeConfig = ''
        blacklist hid_sensor_hub
      '';
    };
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    services.physlock.lockOn.suspend = true;
    ${domain}.networking.nat.externalInterface = "wlp166s0";
  };
}
