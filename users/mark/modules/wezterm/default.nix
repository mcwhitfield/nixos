{
  pkgs,
  wezterm,
  ...
}: {
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
        hash = "sha256-sj3S1fWC6j9Q/Yc+4IpLbKC3lttUWFk65ROyCdQt+Zc=";
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
}
