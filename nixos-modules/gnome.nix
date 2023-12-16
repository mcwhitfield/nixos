{
  self,
  pkgs,
  ...
}: {
  imports = [
    ./desktopEnvironment.nix
  ];

  config = {
    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-photos
        gnome-tour
        gnome.cheese
        gnome.gnome-music
        gnome.gnome-terminal
        gnome.gedit
        gnome.epiphany
        gnome.geary
        gnome.evince
        gnome.gnome-characters
        gnome.totem
        gnome.tali
        gnome.iagno
        gnome.hitori
        gnome.atomix
      ];

      systemPackages = with pkgs; [
        gnome.adwaita-icon-theme
        gnome.gnome-tweaks
      ];
    };

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
