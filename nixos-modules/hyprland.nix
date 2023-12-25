{
  self,
  hyprland,
  ...
}: {
  imports = with self.nixosModules; [
    hyprland.nixosModules.default
    desktop-environment
  ];
  services.xserver.displayManager.defaultSession = "hyprland";
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
