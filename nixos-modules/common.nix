{
  self,
  domain,
  ...
}: {
  imports = [
    self.nixosModules.secrets
    ./configs/locale.nix
    ./configs/network
    ./configs/network/tailscale.nix
    ./configs/nix.nix
    ./configs/persist.nix
  ];

  config.${domain} = {
    locale.enable = true;
    network.enable = true;
    network.tailscale.enable = true;
    nix.enable = true;
    persist.enable = true;
  };
}
