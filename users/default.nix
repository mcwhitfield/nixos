{
  inputs,
  secrets,
  userModules,
  lib,
  ...
} @ flakeCtx: let
  inherit (builtins) mapAttrs attrValues removeAttrs;
  inherit (lib) homeManagerConfiguration;
  inherit (lib.flakes) subpackagesOf;
  inherit (lib.systems) eachSystem;
  inherit (lib.trivial) apply compose;

  mkHomeConfiguration = system: user: path:
    homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {inherit system;};
      extraSpecialArgs = removeAttrs flakeCtx ["lib"] // {inherit user system;};
      modules = [
        inputs.agenix.homeManagerModules.age
        secrets
        userModules.common
        /${path}/home.nix
      ];
    };
  nixosModules = subpackagesOf ./.;
  mkHomeConfigurations = system: mapAttrs (mkHomeConfiguration system) nixosModules;
in rec {
  inherit nixosModules;
  homeConfigurations = eachSystem mkHomeConfigurations;
}
