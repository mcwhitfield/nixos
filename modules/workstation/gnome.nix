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
        cheese
        gnome.gnome-music
        gnome-terminal
        gedit
        epiphany
        geary
        evince
        gnome.gnome-characters
        totem
        gnome.tali
        gnome.iagno
        gnome.hitori
        gnome.atomix
      ];

      systemPackages = with pkgs; [
        adwaita-icon-theme
        gnome-tweaks
      ];
    };

    services.xserver.desktopManager.gnome.enable = true;
  };
}
