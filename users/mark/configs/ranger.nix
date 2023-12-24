{pkgs, ...}: {
  home.packages = with pkgs; [
    drawio
    ffmpegthumbnailer
    fontforge-gtk
    gnutar
    highlight
    librsvg
    jq
    mediainfo
    openscad
    poppler_utils
    ranger
    transmission-gtk
    w3m
  ];
}
