{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "workstation" "gdm"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Configure a workstation with a GNOME Display Manager.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    services.xserver.displayManager.gdm = {
      enable = true;
      banner = config.networking.hostName;
    };
  };
}
