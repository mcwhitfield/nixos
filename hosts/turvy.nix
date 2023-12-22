{self, ...}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    hyprland
    vaultwarden
    steam
    yubikey
    users-mark
  ];

  config = {
    boot.plymouth.enable = false;
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (self.lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;
  };
}
