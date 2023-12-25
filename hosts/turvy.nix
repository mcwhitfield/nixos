{self, ...}: {
  imports = with self.nixosModules; [
    flipper-zero
    framework-16
    gnome
    hyprland
    vaultwarden
    yubikey
    users-mark
  ];

  config = {
    boot.plymouth.enable = false;
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;
  };
}
