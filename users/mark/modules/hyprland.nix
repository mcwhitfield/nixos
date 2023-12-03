# not working
{...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      bindm = [
      ];
    };
  };
}
