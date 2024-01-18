{
  self,
  config,
  domain,
  ...
}: let
  inherit (builtins) any attrValues;
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "services" "reverseProxy"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = any (u: u != null) (attrValues cfg.upstream);
      description = ''
        Enable Caddy reverse proxy to the specified port.
      '';
    };
    upstream = mkOption {
      type =
        types.submodule {
          options = {
            port = mkOption {
              type = types.nullOr types.port;
              default = null;
              example = 8080;
              description = "Port on which the upstream server listens.";
            };
            socket = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "/run/gitlab/gitlab-workhorse.socket";
              description = "Unix socket on which the upstream server listens.";
            };
          };
        }
        // {
          check = opt:
            self.lib.assertMsg (opt.socket == null || opt.port == null) ''
              Must set at most one upstream option; both "port" and "socket" were set.
            '';
        };
      default = {};
      description = ''
        Specifies the upstream which Caddy will proxy requests to.
      '';
    };
    hostName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = ''
        Hostname of the proxied service (locally, on the privateNetwork, and on the tailnet).
      '';
    };
  };

  config = mkIf (cfg.enable) {
    services.caddy = let
      subdomain = "${cfg.hostName}.${config.${domain}.networking.tailscale.tailnet}";
      upstream =
        if (cfg.upstream.port != null)
        then "http://localhost:${toString cfg.upstream.port}"
        else "unix/${cfg.upstream.socket}";
    in {
      enable = true;
      virtualHosts.${subdomain}.extraConfig = ''
        reverse_proxy ${upstream}
      '';
    };
  };
}
