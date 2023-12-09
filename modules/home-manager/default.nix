{self, ...}: {
  imports = with self.homeManagerModules; [
    secrets
  ];

  config.programs.bash.enable = true;
  config.programs.home-manager.enable = true;
}
