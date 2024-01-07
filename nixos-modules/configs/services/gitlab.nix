{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkOption mkIf types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "services" "gitlab"];
  cfg = attrByPath configKey {} config;

  hostConfig = config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable GitLab repository hosting service.
    '';
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
      config = {config, ...}: {
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
          services.reverseProxy.upstream.socket = "/run/${cfg.user}/gitlab-workhorse.socket";
        };

        services.gitlab = {
          enable = true;
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
      };
    };
  };
}
