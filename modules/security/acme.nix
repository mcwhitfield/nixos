{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkForce mkOption mkIf types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "security" "acme"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable SSL Cert management via ACME/Let's Encrypt.
      '';
    };
    domain = mkOption {
      type = types.str;
      default = "${config.networking.hostName}.${domain}";
      description = "The full domain name of the cert to be generated.";
    };
  };

  config = mkIf (cfg.enable) {
    ${domain} = {
      secrets."namecheap-creds".owner = config.security.acme.certs.${cfg.domain}.group;
      persist.directories = [config.security.acme.certs.${cfg.domain}.directory];
    };
    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "mark@${domain}";
      certs.${cfg.domain} = {
        dnsProvider = "namecheap";
        credentialsFile = config.age.secrets."namecheap-creds".path;
      };
    };
    services.nginx = {
      recommendedTlsSettings = true;
      virtualHosts.${cfg.domain} = {
        forceSSL = true;
        useACMEHost = "${cfg.domain}";
      };
    };
    # https://github.com/NixOS/nixpkgs/issues/85794 -- none of these workarounds work, so just
    # a hack for now. Should come back to it later.
    systemd.services."acme-${cfg.domain}" = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = mkForce 30;
        RestartMaxDelaySec = 120;
        RestartSteps = 5;
      };
    };
    users.users.nginx.extraGroups = ["acme"];
  };
}
