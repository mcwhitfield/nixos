{
  self,
  hyprland,
  ...
}: {
  imports = [
    hyprland.nixosModules.default
    self.nixosModules.desktopEnvironment
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
