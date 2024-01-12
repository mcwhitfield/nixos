{
  description = "Home Network";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-shell.url = "github:aciceri/agenix-shell";
    caps2superesc.url = "git+ssh://git@github.com/mcwhitfield/caps2superesc";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakeParts.url = "github:hercules-ci/flake-parts";
    fps = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixosGenerators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixosHardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/nur";
    tokyonight = {
      url = "github:stronk-dev/Tokyo-Night-Linux";
      flake = false;
    };
    wallpapers = {
      url = "github:makccr/wallpapers";
      flake = false;
    };
    wezterm = {
      url = "github:wez/wezterm?submodules=1";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    agenix,
    agenix-shell,
    caps2superesc,
    flakeParts,
    nixpkgs,
    nur,
    ...
  }: let
    inherit (builtins) baseNameOf listToAttrs;
    inherit (nixpkgs.lib) nixosSystem;
    inherit (nixpkgs.lib.strings) removeSuffix;
    constants = import ./inputs/constants.nix;
    dockerhub = import ./inputs/dockerhub.nix;
    ctx = inputs // constants // dockerhub;

    mkConf = m: {
      name = removeSuffix ".nix" (baseNameOf m);
      value = nixosSystem {
        modules = [m ./nixos-modules];
        specialArgs = ctx;
      };
    };
    mkNixosConfigs = ms: listToAttrs (map mkConf ms);
  in
    flakeParts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        images = {
          rpi-bootstrap = self.nixosConfigurations.rpi-bootstrap.config.system.build.sdImage;
        };
        lib = import ./lib ctx;
        nixosConfigurations = mkNixosConfigs [
          ./hosts/turvy
          ./hosts/rpi-0-0.nix
          ./hosts/rpi-0-1.nix
          ./hosts/rpi-bootstrap.nix
        ];
        nixosModules = {
          default = ./nixos-modules/default.nix;
          container-default = ./nixos-modules/container-default.nix;
          common = ./nixos-modules/common.nix;
          rpi = ./nixos-modules/rpi.nix;
          secrets = ./secrets/nixos.nix;
          users-mark = ./users/mark/nixos.nix;
        };
        homeModules = {
          default = ./home-modules;
          secrets = ./secrets/home-manager.nix;
        };
      };

      perSystem = {
        config,
        pkgs,
        lib,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [agenix.overlays.default caps2superesc.overlays.default];
        };
        devShells.default = pkgs.mkShell {
          name = "dev";
          packages = with pkgs; [
            pkgs.agenix
            home-manager
            nixos-rebuild
            gnumake
          ];
        };
      };
    };
}
