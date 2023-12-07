sysCtx @ {self, ...}: let
in rec {
  imports = [
    self.nixosModules.networks.home
    self.nixosModules.users.mark
  ];
}
