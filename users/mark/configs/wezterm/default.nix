{
  self,
  pkgs,
  wezterm,
  osConfig,
  domain,
  ...
}: {
  config = self.lib.mkIf (osConfig.${domain}.workstation.enable) {
    programs.wezterm = {
      enable = true;
      package = pkgs.rustPlatform.buildRustPackage {
        inherit (pkgs.wezterm) name buildInputs nativeBuildInputs postInstall postPatch postUnpack;
        inherit (pkgs.wezterm) preFixup passthru meta buildFeatures;
        version = "nightly";
        src = pkgs.fetchFromGitHub {
          owner = "wez";
          repo = "wezterm";
          rev = wezterm.rev;
          fetchSubmodules = true;
          hash = "sha256-hhAGDnBE0cPtaKhWf8JXeMZVjyRpp79AzYQFRuygO8c=";
        };
        cargoLock = {
          lockFile = "${wezterm}/Cargo.lock";
          outputHashes = {
            # "xcb-1.2.1" = "sha256-zkuW5ATix3WXBAj2hzum1MJ5JTX3+uVQ01R1vL6F1rY=";
            "xcb-imdkit-0.3.0" = "sha256-fTpJ6uNhjmCWv7dZqVgYuS2Uic36XNYTbqlaly5QBjI=";
          };
        };
      };
      extraConfig = builtins.readFile ./config.lua;
    };
  };
}
