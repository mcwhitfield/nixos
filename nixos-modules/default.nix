inputs @ {
  self,
  config,
  pkgs,
  home-manager,
  nixosGenerators,
  disko,
  domain,
  ...
}: let
  inherit (builtins) filter match;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.lists) flatten;
  inherit (self.lib.strings) hasSuffix;
  inherit (self.lib.trivial) pipe;
in {
  imports = flatten [
    home-manager.nixosModules.home-manager
    nixosGenerators.nixosModules.all-formats
    ./common.nix
    (pipe
      ./configs
      [
        listFilesRecursive
        (filter (f: (hasSuffix ".nix" (toString f))))
        (filter (f: (match ".*/_.*\\.nix" (toString f)) == null))
      ])
  ];

  config = {
    system.stateVersion = "23.11";

    boot = {
      initrd.availableKernelModules = ["zfs"];
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
      zfs.extraPools = ["zpool-${config.networking.hostName}"];
      zfs.devNodes = "/dev/disk/by-id";
    };

    environment.systemPackages = with pkgs; [
      disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      lshw
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
    };

    ${domain} = {
      yubikey.enable = true;
    };
  };
}
