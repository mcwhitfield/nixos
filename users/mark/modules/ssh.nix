{ config, ... }:
{
    programs.ssh = {
        enable = true;
        matchBlocks = {
            "git.github.com" = {
                hostname = "github.com";
                user = "git";
                identityFile = config.age.secrets."mark-ssh-0".path;
              };
          };
      };
  }
