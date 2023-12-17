{config, ...}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  homeDir = config.home.homeDirectory;
in {
  imports = [./impermanence.nix];
  home.file.".config".source = mkOutOfStoreSymlink "${config.xdg.configHome}";
  home.persistDirs = with config.xdg.userDirs; [
    desktop
    documents
    download
    music
    pictures
    publicShare
    templates
    videos
  ];
  xdg = {
    enable = true;
    configHome = "${homeDir}/config";
    cacheHome = "${homeDir}/cache";
    dataHome = "${homeDir}/data";
    stateHome = "${homeDir}/state";

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${homeDir}/desktop";
      documents = "${homeDir}/documents";
      download = "${homeDir}/download";
      music = "${homeDir}/music";
      pictures = "${homeDir}/pictures";
      publicShare = "${homeDir}/public";
      templates = "${homeDir}/templates";
      videos = "${homeDir}/videos";
    };
  };
}
