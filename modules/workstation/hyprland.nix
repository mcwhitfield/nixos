{
  self,
  config,
  domain,
  hyprland,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "workstation" "hyprland"];
  cfg = attrByPath configKey {} config;
in {
  imports = [
    hyprland.nixosModules.default
  ];

  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configure the workstation with a Hyprland wayland compositor.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
