{
  description = "Home Network";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ezConfigs.url = "github:ehllie/ez-configs";
    firefly-iii.url = "github:mcwhitfield/firefly-iii-nix";
    fishPlugins-tide = {
      url = "github:IlanCosman/tide/v6.0.1";
      flake = false;
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
    nur.url = "github:nix-community/nur";
    rustOverlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    ezConfigs,
    flakeParts,
    nixpkgs,
    nur,
    rustOverlay,
    ...
  }: let
    constants = import ./inputs/constants.nix;
    dockerhub = import ./inputs/dockerhub.nix;
    ctx = inputs // constants // dockerhub;
  in
    flakeParts.lib.mkFlake {inherit inputs;} {
      imports = [
        ezConfigs.flakeModule
        ./lib
      ];

      systems = [
        "x86_64-linux"
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = ctx;
        home.configurationsDirectory = ./users;
        home.modulesDirectory = ./home-modules;
        nixos.configurationsDirectory = ./hosts;
        nixos.modulesDirectory = ./nixos-modules;
      };

      flake = {
        nixosModules.secrets = ./secrets/nixos.nix;
        nixosModules.users-mark = ./users/mark/nixos.nix;
        homeManagerModules.secrets = ./secrets/home-manager.nix;
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
          overlays = [agenix.overlays.default];
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
