{config, ...}: {
  programs.nushell = {
    enable = true;
    environmentVariables = config.home.sessionVariables;
    configFile.source = ./config.nu;
  };
}
