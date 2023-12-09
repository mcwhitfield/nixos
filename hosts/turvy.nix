{
  self,
  pkgs,
  ...
}: {
  imports = with self.nixosModules; [
    framework16
    gnome
    vaultwarden
  ];

  config = {
    networking.hostName = "turvy";

    environment.systemPackages = with pkgs; [
      git
      home-manager
      vim
      fzf
    ];
  };
}
