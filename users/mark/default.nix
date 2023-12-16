{
  self,
  pkgs,
  config,
  nixosRoot,
  osConfig,
  impermanence,
  ...
}: let
  inherit (builtins) filter;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) hasSuffix removePrefix;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  user = "mark";
  homeDir = "/home/${user}";
  persistenceDir = "/persist${homeDir}";
  userConfigs = filter (hasSuffix ".nix") (listFilesRecursive ./configs);
in {
  imports = with self.homeModules;
    userConfigs
    ++ [
      default
      firacode
      impermanence.nixosModules.home-manager.impermanence
    ];

  config = {
    _module.args = {
      inherit user persistenceDir;
    };
    accounts.email.accounts.${user} = {
      address = "${user}@${osConfig.networking.domain}";
      primary = true;
    };
    age.identityPaths = ["${config.home.homeDirectory}/.ssh/ssh-mark-ed25519"];
    home = {
      username = user;
      homeDirectory = homeDir;
      stateVersion = "23.11";
      packages = with pkgs; [
        dolphin
        nix-output-monitor
      ];
      file.".config".source = mkOutOfStoreSymlink "/${config.xdg.configHome}";
      keyboard.options = [
        "caps:escape"
      ];
      sessionVariables = {
        DIRENV_LOG_FORMAT = "\"\"";
      };
      persistence.${persistenceDir} = {
        directories = with config.xdg;
          (with userDirs;
            map (removePrefix homeDir) [
              desktop
              documents
              download
              music
              pictures
              publicShare
              templates
              videos
            ])
          ++ [
            ".gnupg"
            ".ssh"
            "/${dataHome}/keyrings"
          ];
        allowOther = true;
      };
    };
    programs.ssh.matchBlocks."*" = {
      host = "*";
      identityFile = config.age.secrets."ssh-mark-ed25519".path;
    };
    xdg = {
      enable = true;
      configHome = /${homeDir}/config;
      cacheHome = /${homeDir}/cache;
      dataHome = /${homeDir}/data;
      stateHome = /${homeDir}/state;
      #
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

      configFile.home-manager.source = config.lib.file.mkOutOfStoreSymlink nixosRoot;
    };
  };
}
