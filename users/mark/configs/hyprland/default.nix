# not working
{
  self,
  config,
  pkgs,
  hyprland,
  tokyonight,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (self.lib.flakes) runtimePath;
  inherit (self.lib.lists) flatten;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  gtk = {
    enable = true;
    font = {
      package = pkgs.font-awesome_5;
      name = "v5";
    };
    iconTheme = {
      package = pkgs.tokyo-night-gtk;
      name = "dark";
    };
    theme = {
      package = pkgs.tokyo-night-gtk;
      name = "dark-b";
    };
  };
  home.packages = flatten (with pkgs; [
    qt6.qtwayland
    (with libsForQt5; [
      polkit-kde-agent
      qt5.qtwayland
    ])
    xdg-desktop-portal-hyprland
  ]);
  programs = {
    swaylock.enable = true;
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    wofi.enable = true;
  };
  services.dunst.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    extraConfig = ''
      source=base.conf
      input {
        kb_options = ${concatStringsSep "," config.home.keyboard.options}
      }
    '';
  };

  xdg.configFile = {
    "waybar".source = "${tokyonight}/.config/waybar";
    "gtk-3.0".source = "${tokyonight}/.config/gtk-3.0";
    "wofi".source = "${tokyonight}/.config/wofi";
    "hypr/base.conf".source = runtimePath config ./base.conf;
  };
}
