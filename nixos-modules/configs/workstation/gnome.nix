{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "workstation" "gnome"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Configure the host with a GNOME desktop environment.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
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

    services.xserver.desktopManager.gnome.enable = true;
  };
}
