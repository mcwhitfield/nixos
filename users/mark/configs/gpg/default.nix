{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "gpg"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable gpg-agent for SSH.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    home.persistDirs = [config.programs.gpg.homedir];
    home.packages = [pkgs.pinentry-qt];
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.configHome}/gnupg";
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        {
          text = config.${domain}.pubKeys."gpg-mark.pub";
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
