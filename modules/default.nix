{
  self,
  domain,
  nixosGenerators,
  ...
}: let
  inherit (self.lib) mkForce;
  sdCardConf = {...}: {
    ${domain} = {
      boot.ssh-decrypt.enable = mkForce false;
      boot.systemd-boot.enable = mkForce false;
      disko.enable = mkForce false;
      persist.enable = mkForce false;
    };
  };
in {
  imports = [
    nixosGenerators.nixosModules.all-formats
  ];

  config = {
    formatConfigs.sd-aarch64 = sdCardConf;
    formatConfigs.sd-aarch64-installer = sdCardConf;
    # this is for some reason the slowest step in a build, and not really that important
    documentation.man.generateCaches = false;
    networking.domain = domain;
    system.stateVersion = "23.11";
  };
}
