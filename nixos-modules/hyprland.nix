{
  self,
  hyprland,
  ...
}: {
  imports = [
    hyprland.nixosModules.default
    ./desktopEnvironment.nix
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
