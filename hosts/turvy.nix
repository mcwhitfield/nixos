{domain, ...}: {
  networking.hostName = "turvy";
  networking.hostId = "30ef06a8";
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.flipperzero.enable = true;

  ${domain} = {
    boot.systemd-boot.enable = true;
    disko.disk = "/dev/disk/by-id/nvme-WDS200T1X0E-00AFY0_21213D800491";
    hardware.framework-12.enable = true;
    workstation = {
      enable = true;
      gnome.enable = true;
      gdm.enable = true;
      hyprland.enable = true;
      defaultSession = "hyprland";
    };
  };
}
