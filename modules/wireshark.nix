{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "wireshark"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install and configure the Wireshark program on the host.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.admins.extraSettings.extraGroups = ["wireshark"];
    programs.wireshark.enable = true;
  };
}
