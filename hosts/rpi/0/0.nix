{domain, ...}: {
  networking.hostId = "bde4503c";
  ${domain} = {
    boot.ssh-decrypt.secretsOnly = true;
    disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNF0W311527E";
    rpi = {
      enable = true;
      cluster = 0;
      node = 0;
    };
    services.vaultwarden.enable = false;
    users.mark.enable = true;
  };
}
