{domain, ...}: {
  networking.hostId = "233a13d9";
  ${domain} = {
    disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNF0W311549R";
    rpi = {
      enable = true;
      cluster = 0;
      node = 2;
    };
    users.mark.enable = true;
  };
}
