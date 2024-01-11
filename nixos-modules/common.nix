{
  self,
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
  ];

  config.${domain} = {
    locale.enable = mkDefault true;
    network.enable = mkDefault true;
    network.cloudflare-dns.enable = mkDefault true;
    network.tailscale.enable = mkDefault true;
    nix.enable = mkDefault true;
    persist.enable = mkDefault true;
  };
}
