{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) getName mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "steam"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Steam installation on the system.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    programs.steam.enable = true;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
  };
}
