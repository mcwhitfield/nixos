# not working
{
  config,
  lib,
  pkgs,
  hyprland,
  nixosRoot,
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
  services.dunst = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    xwayland.enable = true;
    extraConfig = ''
      source=base.conf
      input {
        kb_options = ${concatStringsSep "," config.home.keyboard.options}
      }
    '';
  };

  xdg.configFile."hypr/base.conf" = let
    path = "users/mark/modules/hyprland/base.conf";
  in {
    source = config.lib.file.mkOutOfStoreSymlink "${nixosRoot}/${path}";
  };
}
