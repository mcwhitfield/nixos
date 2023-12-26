{
  self,
  config,
  ...
}: {
  imports = with self.nixosModules; [
    firefly-iii
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
    # https://github.com/NixOS/nixpkgs/issues/226365
    networking.firewall.interfaces."podman+".allowedUDPPorts = [53];
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;

    services.firefly-iii = {
      enable = true;
      enableImpermanenceIntegration = true;
      app.secrets.source = config.age.secrets."firefly-iii-app".path;
      app.settings.siteOwner = config.home-manager.users.mark.accounts.email.accounts.mark.address;
      db.secrets.source = config.age.secrets."firefly-iii-db".path;
      importer.secrets.source = config.age.secrets."firefly-iii-importer".path;
    };
  };
}
