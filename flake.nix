{
  description = "Home Network";

  inputs = {
    agenix-shell.url = "github:aciceri/agenix-shell";
    caps2superesc.url = "git+ssh://git@github.com/mcwhitfield/caps2superesc";
    flakeParts.url = "github:hercules-ci/flake-parts";
    fps.url = "github:wamserma/flake-programs-sqlite";
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixosGenerators.url = "github:nix-community/nixos-generators";
    nixosHardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/nur";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    flakeParts,
    ...
  }: let
    constants = import ./inputs/constants.nix;
    dockerhub = import ./inputs/dockerhub.nix;
    ctx = inputs // constants // dockerhub;
  in
    flakeParts.lib.mkFlake {inherit inputs;} rec {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = rec {
        lib = import ./lib ctx;

        hosts = lib.flakes.importNixosConfigsRecursive ctx ./hosts;
        images = lib.flakes.importSubmodulesRecursive ./images;
        nixos-modules = lib.flakes.enumeratePackage ./nixos-modules;
        home-modules = lib.flakes.enumeratePackage ./home-modules;
        users = lib.flakes.enumeratePackage ./users;
        secrets = lib.filesystem.enumerateFiles ./secrets;

        nixosConfigurations = hosts;
        nixosModules = nixos-modules;
        homeModules = home-modules;
      };

      perSystem = sysCtx @ {...}: {
        devShells = flake.lib.flakes.importSubmodulesRecursive (ctx // sysCtx) ./shells;
      };
    };
}
