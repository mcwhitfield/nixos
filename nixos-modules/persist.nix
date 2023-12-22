{impermanence, ...}: {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  environment = {
    persistence."/persist" = {
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/etc/ssh"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  # Allow "sudo" access to user files in /persist/home
  programs.fuse.userAllowOther = true;
}
