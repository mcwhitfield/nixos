{
  self,
  config,
  domain,
  ...
}: {
  imports = [./common.nix];
  config = {
    boot.isContainer = true;
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [80];
      };
      useHostResolvConf = self.lib.mkForce false;
    };
    services.resolved.enable = true;
    ${domain} = {
      persist.manageFileSystems = false;
      persist.mounts.system = "/containers/${config.networking.hostName}";
    };
  };
}
