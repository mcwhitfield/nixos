flakeCtx @ {
  self,
  inputs,
  mkHomeNetworkSystem,
  ...
}: let
  firstPartyModules = with self.nixosModules; [
    hardware.framework16
    ./configuration.nix

    toolchains
    vaultwarden
  ];
  thirdPartyModules = with inputs; [
    fps.nixosModules.programs-sqlite
  ];
in
  mkHomeNetworkSystem {modules = firstPartyModules ++ thirdPartyModules;}
