inputs @ {
  self,
  config,
  home-manager,
  ...
}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    hyprland
    vaultwarden
    home-manager.nixosModules.home-manager
  ];

  config = {
    networking.hostName = "turvy";
    networking.hostId = "30ef06a8";
            home-manager = {
	    useGlobalPkgs = true;
            useUserPackages = true;
            users.mark = self.nixosModules.mark;
	    extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"]; 
	    };
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.podman.dockerSocket.enable = true;
    services.physlock.lockOn.suspend = true;
    environment.persistence."/persist".files =
      builtins.concatMap (label: [
        "/etc/ssh/ssh_host_${label}_key"
        "/etc/ssh/ssh_host_${label}_key.pub"
      ])
      ["rsa" "ed25519"];
  };
}
