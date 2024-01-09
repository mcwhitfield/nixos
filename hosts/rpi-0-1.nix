{
  domain,
  nixosHardware,
  ...
}: {
  imports = [
    nixosHardware.nixosModules.raspberry-pi-4
  ];

  config = {
    networking.hostId = "118bb6f0";
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.generic-extlinux-compatible.enable = false;
    boot.loader.systemd-boot.enable = true;
    boot.initrd.network.ssh.hostKeys = [./tmp-host-key];
    ${domain} = {
      network.nat.externalInterface = "end0";
      disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNF0W311551X";
      rpi = {
        enable = true;
        cluster = 0;
        node = 1;
      };
      services.vaultwarden.enable = true;
      users.mark.enable = true;
    };
  };
}
