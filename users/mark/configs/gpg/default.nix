{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "gpg"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable gpg-agent for SSH.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    home.persistDirs = [config.programs.gpg.homedir];
    home.packages = [pkgs.pinentry-qt];
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
      pinentryFlavor = "qt";
      sshKeys = ["58794282C1DB5CE484DC83336CDC1065109E9D2B"];
    };
  };
}
