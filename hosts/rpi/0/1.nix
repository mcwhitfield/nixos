{
  self,
  domain,
  ...
}: {
  imports = [self.nixosModules.rpi self.nixosModules.users-mark];
  networking.hostId = "118bb6f0";
  ${domain} = {
    disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNF0W311551X";
    rpi = {
      enable = true;
      cluster = 0;
      node = 1;
    };
    services.gitlab.enable = true;
    users.mark.enable = true;
  };
}
