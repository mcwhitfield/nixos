{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkOption mkIf types;
  inherit (self.lib.attrsets) attrByPath genAttrs selfAndAncestorsEnabled setAttrByPath;
  inherit (self.lib.trivial) const flip pipe;
  configKey = [domain "services" "gitlab"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable GitLab repository hosting service.
    '';
    port = mkOption {
      type = types.port;
      default = 8080;
      readOnly = true;
      description = "Port on which the Gitlab server listens.";
    };
    hostName = mkOption {
      type = types.str;
      default = "gitlab";
      description = ''
        Hostname of the container (locally, on the privateNetwork, and on the tailnet).
      '';
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain} = {
      containers.${cfg.hostName} = {
        config = {...}: {
          networking.hostName = cfg.hostName;

          services.gitlab = {
            enable = true;
            host = cfg.hostName;
            port = cfg.port;
            initialRootEmail = config.home-manager.users.mark.accounts.email.accounts.mark.address;
            databasePasswordFile = config.age.secrets."gitlab-db-pass".path;
            initialRootPasswordFile = config.age.secrets."gitlab-root-pass".path;
            secrets = {
              dbFile = config.age.secrets."gitlab-db".path;
              jwsFile = config.age.secrets."gitlab-jws".path;
              otpFile = config.age.secrets."gitlab-otp".path;
              secretFile = config.age.secrets."gitlab-secret".path;
            };
          };
          services.nginx = {
            enable = true;
            recommendedProxySettings = true;
            virtualHosts.${cfg.hostName}.locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}";
              proxyWebsockets = true;
            };
          };
          ${domain}.persist.directories = [config.services.gitlab.statePath];
        };
      };
    };
  };
}
