{
  config,
  domain,
  ...
}: {
  imports = [./common.nix];
  config = {
    boot.isContainer = true;
    ${domain} = {
      persist.manageFileSystems = false;
      persist.mounts.system = "/containers/${config.networking.hostName}";
    };
  };
}
