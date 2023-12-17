{config, ...}: {
  # Preserve `direnv allow` across reboots.
  home.persistDirs = ["${config.xdg.dataHome}/direnv"];
  home.sessionVariables.DIRENV_LOG_FORMAT = "\"\"";

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
