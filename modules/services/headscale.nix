{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "headscale"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run a https://headscale.net server on this host.
      '';
    };
    subdomain = mkOption {
      type = types.str;
      default = "headscale";
      description = "The subdomain under ${domain} on which Headscale will serve requests.";
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [config.services.headscale.package];
    ${domain}.persist.directories = ["/var/lib/headscale"];
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8080;
        settings = {
          ip_prefixes = ["100.64.0.0/10"];
          server_url = "https://${cfg.subdomain}.${domain}";
          logtail.enabled = false;
        };
      };
      nginx.virtualHosts."${cfg.subdomain}.${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
