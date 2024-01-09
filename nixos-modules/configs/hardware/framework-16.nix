{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "hardware" "framework16"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Common configuration for Framework 16 laptop hardware support.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    boot = {
      binfmt.emulatedSystems = ["aarch64-linux"];
      initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
      # https://community.frame.work/t/solved-guide-12th-gen-not-sending-xf86monbrightnessup-down/20605
      extraModprobeConfig = ''
        blacklist hid_sensor_hub
      '';
    };
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    services.physlock.lockOn.suspend = true;
    swapDevices = [];
    ${domain}.network.nat.externalInterface = "wlp166s0";
  };
}
