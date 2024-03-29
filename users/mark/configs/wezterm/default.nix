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
          hash = "sha256-7mA51U/3iPoXvYcDy5WEY4Ve0c5ey+vsxaKo9UoGjFE=";
        };
        cargoLock = {
          lockFile = "${wezterm}/Cargo.lock";
          outputHashes = {
            "xcb-1.2.1" = "sha256-zkuW5ATix3WXBAj2hzum1MJ5JTX3+uVQ01R1vL6F1rY=";
            "xcb-imdkit-0.2.0" = "sha256-L+NKD0rsCk9bFABQF4FZi9YoqBHr4VAZeKAWgsaAegw=";
          };
        };
      };
      extraConfig = builtins.readFile ./config.lua;
    };
  };
}
