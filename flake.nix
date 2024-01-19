{
  description = "Home Network";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    caps2superesc.url = "git+ssh://git@github.com/mcwhitfield/caps2superesc";
    disko.url = "github:nix-community/disko";
    flakeParts.url = "github:hercules-ci/flake-parts";
    fps.url = "github:wamserma/flake-programs-sqlite";
    home-manager.url = "github:nix-community/home-manager";
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixosGenerators.url = "github:nix-community/nixos-generators";
    nixosHardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/nur";
    tokyonight.url = "github:stronk-dev/Tokyo-Night-Linux";
    wallpapers.url = "github:makccr/wallpapers";
    wezterm.url = "github:wez/wezterm?submodules=1";

    agenix.inputs.nixpkgs.follows = "nixpkgs";
    caps2superesc.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    fps.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    nixosGenerators.inputs.nixpkgs.follows = "nixpkgs";

    tokyonight.flake = false;
    wallpapers.flake = false;
    wezterm.flake = false;
  };

  outputs = inputs @ {
    self,
    flakeParts,
    ...
  }:
    flakeParts.lib.mkFlake {inherit inputs;} rec {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = rec {
        lib = import ./lib inputs;

        domain = "whitfield.one";
        hosts = lib.flakes.importNixosConfigsRecursive inputs ./hosts;
        modules = lib.flakes.enumeratePackage ./modules;
        home-modules = lib.flakes.enumeratePackage ./home-modules;
        users = lib.flakes.enumeratePackage ./users;
        secrets = lib.filesystem.enumerateFiles ./secrets;

        nixosConfigurations = lib.attrsets.implode "-" hosts;
        nixosModules = let
          flattenedModules = lib.attrsets.implode "/" modules;
          userModules = lib.attrsets.mapValues (cfgs: cfgs.nixos) users;
        in
          flattenedModules // userModules;
        homeModules = lib.attrsets.implode "/" home-modules;
      };

      perSystem = sysCtx @ {...}: {
        devShells = flake.lib.flakes.importSubmodulesRecursive (inputs // sysCtx) ./shells;
      };
    };
}
