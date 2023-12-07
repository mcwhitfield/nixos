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
    fps = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.11";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    "fishPlugins.tide" = {
      url = "github:IlanCosman/tide/v6.0.1";
      flake = false;
    };
  };

  outputs = flakes @ {self, ...}: let
    context = rec {
      inherit self;
      inputs =
        builtins.removeAttrs flakes ["self"]
        // import ./inputs/dockerhub.nix context;
      network = import ./networks/home.nix context;
      nixosRoot = "/etc/nixos";
      secrets = ./secrets;
    };
  in
    with context; rec {
      hardware = import ./hardware context;
      homeModules = import ./modules/home-manager context;
      homeConfigurations = users.homeConfigurations;
      lib = import ./lib context;
      networks = import ./networks context;
      nixosModules =
        import ./modules/nixos context
        // {
          inherit secrets hardware networks;
          users = users.nixosModules;
        };
      nixosConfigurations = systems;
      systems = import ./systems context;
      users = import ./users context;
    };
}
