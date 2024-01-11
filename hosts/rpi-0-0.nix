{
  self,
  domain,
  ...
}: {
  imports = with self.nixosModules; [
    rpi
    users-mark
  ];

  config = {
    networking.hostId = "bde4503c";
    boot.initrd.network.ssh.hostKeys = [./tmp-host-key];
    ${domain} = {
      network.nat.externalInterface = "end0";
      disko.disk = "/dev/disk/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usbv3-0:1:1.0-scsi-0:0:0:0";
      rpi = {
        enable = true;
        cluster = 0;
        node = 0;
      };
      services.vaultwarden.enable = true;
      users.mark.enable = true;
    };
  };
}
