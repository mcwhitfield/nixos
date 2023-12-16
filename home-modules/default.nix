{self, ...}: {
  imports = with self.homeManagerModules; [
    secrets
  ];

  programs.bash.enable = true;
  programs.home-manager.enable = true;
  systemd.user.services.agenix.Unit.After = [
    "basic.target"
  ];
}
