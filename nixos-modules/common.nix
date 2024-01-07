{
  self,
  domain,
  ...
}: {
  imports = [
    self.nixosModules.secrets
    ./configs/acme.nix
    ./configs/locale.nix
    ./configs/network/cloudflare-dns.nix
    ./configs/network/default.nix
    ./configs/network/tailscale.nix
    ./configs/nix.nix
    ./configs/persist.nix
    ./configs/services/reverse-proxy.nix
  ];

  config.${domain} = {
    locale.enable = true;
    network.enable = true;
    network.cloudflare-dns.enable = true;
    network.tailscale.enable = true;
    nix.enable = true;
    persist.enable = true;
  };
}
