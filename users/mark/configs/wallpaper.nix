{
  self,
  domain,
  config,
  osConfig,
  wallpapers,
  ...
}: {
  config = self.lib.mkIf (osConfig.${domain}.workstation.enable) {
    programs.wpaperd = {
      enable = true;
      settings = {
        default = {
          path = "${wallpapers}/wallpapers/";
          duration = "30m";
        };
      };
    };
    systemd.user.services.wpaperd = {
      Unit = {
        Description = "Wpaperd -- rotates wallpaper on a schedule.";
        After = ["wayland.service"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${self.lib.getExe config.programs.wpaperd.package} --no-daemon";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
