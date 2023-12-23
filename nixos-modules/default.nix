{
  self,
  nixosGenerators,
  ...
}: {
  imports = with self.nixosModules; [
    nixosGenerators.nixosModules.all-formats
    locale
    network
    nix
    persist
    secrets
  ];

  config = {
    system.stateVersion = "23.11";

    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
    };
  };
}
