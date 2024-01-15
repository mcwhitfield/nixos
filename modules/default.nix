inputs @ {
  config,
  pkgs,
  home-manager,
  nixosGenerators,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    nixosGenerators.nixosModules.all-formats
  ];

  config = {
    system.stateVersion = "23.11";

    boot = {
      initrd = {
        availableKernelModules = ["zfs"];
        systemd.initrdBin = [pkgs.busybox];
      };
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
      zfs.extraPools = ["zpool-${config.networking.hostName}"];
      zfs.devNodes = "/dev/disk/by-id";
    };

    environment.systemPackages = with pkgs; [
      busybox
      lshw
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
    };
  };
}
