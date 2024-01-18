{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "podman"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = config.virtualisation.oci-containers.containers != {};
      description = ''
        Enable common Podman configuration for hosts on ${domain}.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.admins.extraGroups = ["podman"];
    firewall.interfaces."podman+".allowedUDPPorts = [53];
    virtualisation.oci-containers.backend = "podman";
  };
}
