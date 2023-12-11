{self, ...}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    hyprland
    vaultwarden
    firefly-iii
  ];

  config = {
    networking.hostName = "turvy";

    services.physlock.lockOn.suspend = true;
  };
}
