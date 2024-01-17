{
  self,
  config,
  osConfig,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  inherit (osConfig.networking) domain;

  configKey = [domain];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable default home-manager configuration for users in ${domain};
      '';
    };
    nixosRoot = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = ''
        Absolute path to the NixOS config flake (i.e. this flake) on the system.
        $XDG_CONFIG_HOME/home-manager will be symlinked to this path.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    programs.bash.enable = true;
    programs.home-manager.enable = true;
    systemd.user.services.agenix.Unit.After = ["basic.target"];
    xdg.configFile.home-manager.source = config.lib.file.mkOutOfStoreSymlink cfg.nixosRoot;
  };
}
