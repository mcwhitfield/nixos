{
  self,
  config,
  ...
}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    hyprland
    vaultwarden
  ];

  config = {
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";

    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;
    environment.persistence."/persistent/${config.networking.hostName}".files =
      builtins.concatMap (label: [
        "/etc/ssh/ssh_host_${label}_key"
        "/etc/ssh/ssh_host_${label}_key.pub"
      ])
      ["rsa" "ed25519"];
  };
}
