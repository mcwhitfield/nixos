{
  config,
  persistenceDir,
  ...
}: {
  # Preserve `direnv allow` across reboots.
  home.persistence.${persistenceDir}.directories = ["/${config.xdg.dataHome}/direnv"];
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
