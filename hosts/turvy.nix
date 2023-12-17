{self, ...}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    hyprland
    vaultwarden
    users-mark
  ];

  config = {
    boot.plymouth.enable = true;
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;
  };
}
