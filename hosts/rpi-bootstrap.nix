{
  self,
  domain,
  nixpkgs,
  nixosHardware,
  ...
}: {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    nixosHardware.nixosModules.raspberry-pi-4
    self.nixosModules.secrets
    self.nixosModules.users-mark
  ];
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.systemd-boot.enable = false;
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
