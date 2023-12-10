{
  description = "Home Network";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
  };

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ezConfigs = {
      url = "github:ehllie/ez-configs";
    };
    flakeParts = {
      url = "github:hercules-ci/flake-parts";
    };
    fps = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.11";
    };
    nur = {
      url = "github:nix-community/nur";
    };
    fishPlugins-tide = {
      url = "github:IlanCosman/tide/v6.0.1";
      flake = false;
    };
    rustOverlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
        home = {
          configurationsDirectory = ./users;
          modulesDirectory = ./modules/home-manager;
        };
        nixos = {
          configurationsDirectory = ./hosts;
          modulesDirectory = ./modules/nixos;
        }; #
      };

      flake = {
        nixosModules.secrets = ./secrets/nixos.nix;
        homeManagerModules.secrets = ./secrets/home-manager.nix;
      };

      perSystem = {
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
          name = "default-shell";
          packages = lib.attrValues {
            inherit
              (pkgs)
              agenix
              home-manager
              nixos-rebuild
              ;
          };
        };
      };
    };
}
