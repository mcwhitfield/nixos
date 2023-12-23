{config, ...}: {
  home.persistDirs = [config.programs.gpg.homedir];
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
    mutableKeys = false;
    mutableTrust = false;
    publicKeys = [
      {
        source = ./public-key;
        trust = 5;
      }
    ];
  };
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    sshKeys = ["58794282C1DB5CE484DC83336CDC1065109E9D2B"];
  };
}
