inputs @ {
  self,
  home-manager,
  nixosGenerators,
  domain,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    nixosGenerators.nixosModules.all-formats
    ./common.nix
    ./configs/caps2superesc.nix
    ./configs/containers.nix
    ./configs/hardware/framework-16.nix
    ./configs/network
    ./configs/network/cloudflare-dns.nix
    ./configs/network/headscale.nix
    ./configs/network/nat.nix
    ./configs/persist.nix
    ./configs/services/firefly-iii
    ./configs/services/gitlab.nix
    ./configs/services/vaultwarden.nix
    ./configs/workstation
    ./configs/workstation/gdm.nix
    ./configs/workstation/gnome.nix
    ./configs/workstation/hyprland.nix
    ./configs/yubikey.nix
  ];

  config = {
    system.stateVersion = "23.11";

    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 25;
      };
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
    };

    ${domain} = {
      network.cloudflare-dns.enable = true;
      yubikey.enable = true;
    };
  };
}
