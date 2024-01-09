{
  self,
  pkgs,
  admin,
  domain,
  ...
}: {
  imports = with self.nixosModules; [
    users-mark
  ];
  config = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 25;
    };
    environment.systemPackages = [pkgs.wirelesstools];
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.flipperzero.enable = true;

    ${domain} = {
      hardware.framework16.enable = true;
      persist = {
        enable = true;
        fileSystems = {
          boot = {
            device = "/dev/disk/by-uuid/1562-7E09";
            fsType = "vfat";
          };
          nix = {
            device = "zpool/nix";
            fsType = "zfs";
          };
          persistent.root = {
            device = "zpool/persist";
            fsType = "zfs";
          };
          persistent.home = {
            device = "zpool/persist/home";
            fsType = "zfs";
          };
        };
      };
      workstation = {
        enable = true;
        gnome.enable = true;
        gdm.enable = true;
        hyprland.enable = true;
        defaultSession = "hyprland";
      };
      services.gitlab.enable = false;
      services.vaultwarden.enable = false;
      services.firefly-iii = {
        enable = true;
        app.settings.siteOwner = admin;
      };
      users.mark.enable = true;
      yubikey.enable = true;
    };
  };
}
