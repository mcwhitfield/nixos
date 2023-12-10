{
  self,
  config,
  pkgs,
  domain,
  nixosRoot,
  nur,
  rustOverlay,
  ...
}: let
  inherit (self) lib nixosModules;
  inherit (lib.attrsets) mapValues;
in {
  imports = with nixosModules; [
    {nixpkgs.overlays = [nur.overlay rustOverlay.overlays.default];}
    secrets
  ];

  config = {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    environment.systemPackages = with pkgs; [
      (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
    ];

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
        flakeToEntry = input: {
          to.path = input;
          to.type = "path";
        };
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
