{hyprland, ...}: {
  imports = [
    hyprland.nixosModules.default
    ./desktopEnvironment.nix
  ];
  services.xserver.displayManager.defaultSession = "hyprland";
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
