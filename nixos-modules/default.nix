inputs @ {
  self,
  home-manager,
  nixosGenerators,
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
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 25;
      };
      supportedFilesystems = ["zfs"];
      tmp.useTmpfs = true;
    };

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
