userCtx @ {
  self,
  user,
  network,
  ...
}: let
  homeDir = "/home/${user}";
  modules = import ./modules userCtx;
in {
  imports = builtins.attrValues modules;

  config = {
    accounts.email.accounts.mark = {
      address = "${user}@${network.networking.domain}";
      primary = true;
    };
    home = {
      username = user;
      homeDirectory = homeDir;
      stateVersion = "23.11";
    };

    programs.bash.enable = true;
    programs.home-manager.enable = true;

    xdg = {
      enable = true;
      configHome = /${homeDir}/config;
      cacheHome = /${homeDir}/cache;
      dataHome = /${homeDir}/data;
      stateHome = /${homeDir}/state;
      userDirs = {
        enable = true;
        createDirectories = true;

        desktop = /${homeDir}/desktop;
        documents = /${homeDir}/documents;
        download = /${homeDir}/download;
        music = /${homeDir}/music;
        pictures = /${homeDir}/pictures;
        publicShare = /${homeDir}/public;
        templates = /${homeDir}/templates;
        videos = /${homeDir}/videos;
      };
    };
  };
}
