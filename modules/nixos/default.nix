{
  self,
  config,
  pkgs,
  domain,
  nixosRoot,
  ...
}: let
  inherit (builtins) attrValues;
  inherit (self) lib nixosModules inputs;
  inherit (lib.attrsets) catAttrs mapValues;
in {
  imports = with nixosModules; [
    {nixpkgs.overlays = catAttrs "overlay" (attrValues inputs);}
    secrets
    toolchains
  ];

  config = {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
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

    networking.domain = domain;
    networking.networkmanager.enable = true;

    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      package = pkgs.nixFlakes;
      registry = let
        flakeToEntry = input: {to.flake = input;};
        selfEntry = {
          nixos.to.type = "path";
          nixos.to.path = nixosRoot;
        };
      in
        mapValues flakeToEntry self.inputs // selfEntry;
    };

    nixpkgs.config.allowUnfree = false;

    services.sshd.enable = true;

    system.stateVersion = "23.11";

    time.timeZone = "America/New_York";

    users.users = {
      mark = {
        hashedPasswordFile = config.age.secrets."mark-password".path;
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
      };
    };
  };
}
