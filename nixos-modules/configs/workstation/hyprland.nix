{
  self,
  config,
  domain,
  hyprland,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "workstation" "hyprland"];
in {
  imports = [
    hyprland.nixosModules.default
  ];

  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Configure the workstation with a Hyprland wayland compositor.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
