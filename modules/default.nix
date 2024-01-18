{
  domain,
  nixosGenerators,
  ...
}: {
  imports = [
    nixosGenerators.nixosModules.all-formats
  ];

  config.networking.domain = domain;
  config.system.stateVersion = "23.11";
}
