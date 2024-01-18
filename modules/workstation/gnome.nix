{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "workstation" "gnome"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configure the host with a GNOME desktop environment.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-photos
        gnome-tour
        gnome.cheese
        gnome.gnome-music
        gnome.gnome-terminal
        gedit
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
