{
  self,
  pkgs,
  nixosRoot,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
    package = pkgs.nixFlakes;
    registry = let
      flakeToEntry = input: {
        to.path = input;
        to.type = "path";
      };
      selfEntry = {
        nixos.to.type = "path";
        nixos.to.path = nixosRoot;
      };
    in
      self.lib.attrsets.mapValues flakeToEntry self.inputs // selfEntry;
    settings.allowed-users = ["@wheel"];
  };
  nixpkgs.config.allowUnfree = false;
}
