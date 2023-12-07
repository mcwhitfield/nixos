flakeCtx @ {
  self,
  inputs,
  secrets,
  ...
}: let
  inherit (self.lib) nixosSystem;
  mkHomeNetworkSystem = args @ {modules, ...}: let
    commonArgs = {
      specialArgs = flakeCtx // {network = self.networks.home;};
      modules =
        modules
        ++ [
          inputs.agenix.nixosModules.default
          secrets
          self.nixosModules.common
        ];
    };
    finalArgs = args // commonArgs;
  in
    nixosSystem finalArgs;
  ctx = flakeCtx // {inherit mkHomeNetworkSystem;};
in
  self.lib.flakes.importAllSubmodules ./. ctx
