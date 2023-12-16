# not working
{
  config,
  lib,
  pkgs,
  hyprland,
  nixosRoot,
  wallpapers,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (lib.lists) flatten;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  home.packages = flatten (with pkgs; [
    qt6.qtwayland
    wofi
    (with libsForQt5; [
      polkit-kde-agent
      qt5.qtwayland
    ])
    xdg-desktop-portal-hyprland
  ]);
  programs.swaylock.enable = true;
  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "${wallpapers}/wallpapers/";
        duration = "30m";
      };
    };
  };
  services.dunst = {
    enable = true;
  };
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

  xdg.configFile."hypr/base.conf" = let
    path = "users/mark/configs/hyprland/base.conf";
  in {
    source = config.lib.file.mkOutOfStoreSymlink "${nixosRoot}/${path}";
  };
}
