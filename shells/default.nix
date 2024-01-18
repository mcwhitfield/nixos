{
  nixpkgs,
  disko,
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
      disko.packages.${system}.disko
      home-manager
      nixos-rebuild
      gnumake
    ];
  }
