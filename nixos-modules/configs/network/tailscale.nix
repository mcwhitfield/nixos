{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "network" "tailscale"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable Tailscale on the system, including necessary networking configs.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain}.persist.directories = ["/var/lib/tailscale"];
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    services.tailscale = {
      enable = true;
    };
  };
}
