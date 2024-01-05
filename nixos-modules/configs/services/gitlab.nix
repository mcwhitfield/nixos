{
  self,
  config,
  domain,
  tailnet,
  ...
}: let
  inherit (self.lib) mkEnableOption mkOption mkIf types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "services" "gitlab"];
  cfg = attrByPath configKey {} config;

  subdomain = "${cfg.hostName}.${tailnet}";
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
    user = mkOption {
      type = types.str;
      default = "gitlab";
      description = ''
        The user that Gitlab services will run as.
      '';
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain}.containers.${cfg.hostName} = {
      config = let
        hostConfig = config;
      in
        {config, ...}: {
          ${domain} = {
            persist.directories = [config.services.gitlab.statePath];
            secrets = {
              "gitlab-db".owner = cfg.user;
              "gitlab-db-pass".owner = cfg.user;
              "gitlab-jws".owner = cfg.user;
              "gitlab-otp".owner = cfg.user;
              "gitlab-root-pass".owner = cfg.user;
              "gitlab-secret".owner = cfg.user;
            };
          };
          networking.hostName = cfg.hostName;

          services.gitlab = {
            enable = true;
            host = cfg.hostName;
            port = cfg.port;
            initialRootEmail = hostConfig.home-manager.users.mark.accounts.email.accounts.mark.address;
            databasePasswordFile = config.age.secrets."gitlab-db-pass".path;
            initialRootPasswordFile = config.age.secrets."gitlab-root-pass".path;
            secrets = {
              dbFile = config.age.secrets."gitlab-db".path;
              jwsFile = config.age.secrets."gitlab-jws".path;
              otpFile = config.age.secrets."gitlab-otp".path;
              secretFile = config.age.secrets."gitlab-secret".path;
            };
          };
          services.caddy = {
            enable = true;
            virtualHosts.${subdomain}.extraConfig = ''
              reverse_proxy unix//run/${cfg.user}/gitlab-workhorse.socket
            '';
            virtualHosts.${cfg.hostName}.extraConfig = ''
              reverse_proxy unix+h2c//run/${cfg.user}/gitlab-workhorse.socket {
                transport http {
                  versions h2c
                }
              }
            '';
          };
        };
    };
  };
}
