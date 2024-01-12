{domain, ...}: {
  networking.hostId = "bde4503c";
  boot.initrd.network.ssh.hostKeys = [./tmp-host-key];
  ${domain} = {
    network.nat.externalInterface = "enabcm6e4ei0";
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
