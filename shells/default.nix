{
  nixpkgs,
  system,
  agenix,
  ...
}: let
  pkgs = nixpkgs.legacyPackages.${system};
in
  pkgs.mkShell {
    name = "dev";
    packages = with pkgs; [
      agenix.packages.${system}.agenix
      home-manager
      nixos-rebuild
      gnumake
    ];
  }
