{
  self,
  pkgs,
  osConfig,
  domain,
  ...
}: {
  config = self.lib.mkIf (osConfig.${domain}.workstation.enable) {
    home.packages = with pkgs; [
      ffmpegthumbnailer
      fontforge-gtk
      gnutar
      highlight
      librsvg
      jq
      mediainfo
      poppler_utils
      ranger
      transmission_3-gtk
      w3m
    ];
  };
}
