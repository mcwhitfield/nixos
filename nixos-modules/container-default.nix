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
      };
      networkmanager.enable = false;
      useHostResolvConf = self.lib.mkForce false;
    };
    ${domain} = {
      persist.mounts.system = "/containers/${config.networking.hostName}";
    };
  };
}
