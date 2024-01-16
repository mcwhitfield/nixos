{
  config,
  nixosRoot,
  ...
}: {
  programs.bash.enable = true;
  programs.home-manager.enable = true;
  systemd.user.services.agenix.Unit.After = [
    "basic.target"
  ];
  xdg.configFile.home-manager.source = config.lib.file.mkOutOfStoreSymlink nixosRoot;
}
