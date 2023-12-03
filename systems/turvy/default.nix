{
  self,
  hardware,
  inputs,
  ...
} @ flakeCtx: let
  systemModules = [./configuration.nix hardware.framework16];
  thirdPartyModules = with inputs; [
    agenix.nixosModules.default
    fps.nixosModules.programs-sqlite
  ];
  firstPartyModules = with self.nixosModules;
    [
      common
      toolchains
      vaultwarden
      secrets
    ]
    ++ [
      users.mark
    ];
in
  inputs.nixpkgs.lib.nixosSystem rec {
    specialArgs = flakeCtx;
    modules = systemModules ++ thirdPartyModules ++ firstPartyModules;
  }
