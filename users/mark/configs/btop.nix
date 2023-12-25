{tokyonight, ...}: {
  programs.btop.enable = true;
  programs.btop.settings = {
    color_theme = "tokyo";
    theme_background = false;
  };
  xdg.configFile."btop/themes".source = "${tokyonight}/.config/bpytop/themes";
}
