{nixosGenerators, ...}: {
  imports = [
    nixosGenerators.nixosModules.all-formats
  ];

  config.system.stateVersion = "23.11";
}
