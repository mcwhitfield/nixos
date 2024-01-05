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
    ${domain} = {
      persist.mounts.system = "/containers/${config.networking.hostName}";
    };
  };
}
