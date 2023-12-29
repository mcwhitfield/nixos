inputs @ {
  self,
  config,
  home-manager,
  nixosGenerators,
  domain,
  ...
}: let
  inherit (builtins) filter match toString;
  inherit (self.lib) mkDefaultEnabled mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.lists) flatten;
  inherit (self.lib.strings) hasSuffix;
  inherit (self.lib.trivial) pipe;
  configKey = [domain];

  myModules = pipe ./. [
    listFilesRecursive
    (filter (hasSuffix ".nix"))
    (filter (f: (match ".*/_[^/]*" (toString f)) == null))
    (filter (f: !(hasSuffix "nixos-modules/default.nix" (toString f))))
    (filter (f: !(hasSuffix "nixos-modules/template.nix" (toString f))))
  ];
in {
  imports = flatten [
    home-manager.nixosModules.home-manager
    nixosGenerators.nixosModules.all-formats
    self.nixosModules.secrets
    myModules
  ];

  options = setAttrByPath configKey {
    enable = mkDefaultEnabled ''
      Enable standardized configuration presets for hosts on ${domain}.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
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

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    programs = {
      wireshark.enable = true;
    };

    time.timeZone = "America/New_York";
  };
}
