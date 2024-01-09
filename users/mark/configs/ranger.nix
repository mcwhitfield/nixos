{
  self,
  pkgs,
  osConfig,
  domain,
  ...
}: {
  config = self.lib.mkIf (osConfig.${domain}.workstation.enable) {
    home.packages = with pkgs; [
      drawio
      ffmpegthumbnailer
      fontforge-gtk
      gnutar
      highlight
      librsvg
      jq
      mediainfo
      poppler_utils
      ranger
      transmission-gtk
      w3m
    ];
  };
}
