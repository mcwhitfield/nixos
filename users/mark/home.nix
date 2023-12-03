userCtx @ {
  self,
  config,
  lib,
  pkgs,
  user,
  network,
  ...
}:
with lib; let
  homeDir = "/home/${user}";
  modules = builtins.attrValues (import ./modules userCtx);
in {
  imports = modules;

  config = {
    accounts.email.accounts.mark = {
      address = "${user}@${network.domain}";
      primary = true;
    };
    home = {
      username = user;
      homeDirectory = homeDir;
      stateVersion = "23.11";

      sessionVariables = {
        NIX_ROOT = "${self}";
	FOO = "bar";
      };
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
