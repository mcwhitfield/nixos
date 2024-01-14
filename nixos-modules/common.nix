{
  self,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) mkDefault;
in {
  imports = [
    self.nixosModules.secrets
    ./configs/acme.nix
    ./configs/disko.nix
    ./configs/locale.nix
    ./configs/network/cloudflare-dns.nix
    ./configs/network/default.nix
    ./configs/network/tailscale.nix
    ./configs/nix.nix
    ./configs/persist.nix
    ./configs/services/reverse-proxy.nix
    ./configs/yubikey.nix
  ];

  config.${domain} = {
    locale.enable = mkDefault true;
    network.enable = mkDefault true;
    network.resolved.enable = mkDefault false;
    network.tailscale.enable = mkDefault true;
    nix.enable = mkDefault true;
    persist.enable = mkDefault true;
    yubikey.enable = mkDefault true;
  };
  config = {
    boot.initrd.systemd.initrdBin = [pkgs.busybox];
    environment.systemPackages = [pkgs.busybox];
  };
}
