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

  outputs = {self, ...} @ flakes: let
    context = rec {
      inherit self;
      nixosRoot = "/etc/nixos";
      secrets = ./secrets;
      inputs =
        builtins.removeAttrs flakes ["self"]
        // import ./inputs/dockerhub.nix context;
      lib = import ./lib context;
      networks = import ./networks context;
      network = networks.home;
      modules = import ./modules context;
      hardware = import ./hardware context;
      userModules = import ./user-modules context;
      users = import ./users context;
      systems = import ./systems context;
      homeConfigurations = users.homeConfigurations;
    };
    extraModules = with context; {
      inherit secrets hardware;
      users = users.nixosModules;
    };
  in
    with context; {
      inherit lib networks homeConfigurations;
      nixosModules = modules // extraModules;
      nixosConfigurations = systems;
    };
}
