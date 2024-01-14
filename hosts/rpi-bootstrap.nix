{
  self,
  pkgs,
  domain,
  ...
}: let
  inherit (builtins) filter listToAttrs map;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) removePrefix;
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
  imports = [
    # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    # nixosHardware.nixosModules.raspberry-pi-4
    self.nixosModules.secrets
    self.nixosModules.users-mark
  ];
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.enable = self.lib.mkForce false;
      systemd-boot = {
        enable = true;
        extraFiles = firmwareFiles;
      };
    };
  }; #
  networking.hostId = "f5d79883";
  networking.hostName = "rpi-bootstrap";
  networking.networkmanager.enable = false;
  networking.wireless.enable = false;
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnsupportedSystem = true;
  ${domain} = {
    users.mark = {
      enable = true;
      enableHomeManager = false;
    };
    network.enable = false;
    network.cloudflare-dns.enable = false;
    network.tailscale.enable = false;
    nix.enable = false;
    persist.enable = false;
  };
}
