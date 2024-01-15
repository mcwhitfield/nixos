{
  self,
  domain,
  ...
}: {
  imports = [self.nixosModules.rpi self.nixosModules.users-mark];
  networking.hostId = "bde4503c";
  ${domain} = {
    disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNF0W311527E";
    rpi = {
      enable = true;
      cluster = 0;
      node = 0;
    };
    services.vaultwarden.enable = true;
    users.mark.enable = true;
  };
}
