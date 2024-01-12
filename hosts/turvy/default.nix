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
    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.flipperzero.enable = true;

    ${domain} = {
      disko.enable = true;
      disko.disk = "/dev/disk/by-id/nvme-WDS200T1X0E-00AFY0_21213D800491";
      hardware.framework16.enable = true;
      persist.enable = true;
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
        enable = false;
        app.settings.siteOwner = admin;
      };
      users.mark.enable = true;
    };
  };
}
