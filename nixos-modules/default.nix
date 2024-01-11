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
    disko.nixosModules.disko
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
      kernelPackages = self.lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
      initrd.availableKernelModules = ["zfs"];
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
      zfs.extraPools = ["zpool-${config.networking.hostName}"];
      zfs.devNodes = "/dev/disk/by-path";
    };

    environment.systemPackages = [
      disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
    };

    ${domain} = {
      network.cloudflare-dns.enable = true;
      yubikey.enable = true;
    };
  };
}
