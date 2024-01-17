{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "tailscale"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable Tailscale on the system, including necessary networking configs.
      '';
    };
    tailnet = mkOption {
      type = types.str;
      default = "tail19498.ts.net";
      description = ''
        The tailnet managing hosts on this domain.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.persist.directories = ["/var/lib/tailscale"];
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
    services.tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = config.services.caddy.user;
    };
  };
}
