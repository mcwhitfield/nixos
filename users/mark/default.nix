{
  self,
  user,
  nixRoot,
  osConfig,
  ...
}: let
  inherit (self.lib.filesystem) listFilesRecursive;
  homeDir = "/home/${user}";
in {
  imports = with self.homeManagerModules;
    listFilesRecursive ./modules
    ++ [
      firacode
    ];

  config = {
    accounts.email.accounts.${user} = {
      address = "${user}@${osConfig.networking.domain}";
      primary = true;
    };
    home = {
      username = user;
      homeDirectory = homeDir;
      stateVersion = "23.11";
    };
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

      configFile.home-manager.source = nixRoot;
    };
  };
}
