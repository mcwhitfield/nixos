{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkOption mkIf types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "services" "vaultwarden"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable Vaultwarden (self-hosted FOSS Bitwarden implementation) password manager service.
    '';
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/bitwarden_rs";
      readOnly = true;
      description = "Absolute path the directory containing Vaultwarden persistent data.";
    };
    port = mkOption {
      type = types.port;
      default = 8222;
      readOnly = true;
      description = "Port on which the Vaultwarden server listens.";
    };
    hostName = mkOption {
      type = types.str;
      default = "vaultwarden";
      description = ''
        Hostname of the container (locally, on the privateNetwork, and on the tailnet).
      '';
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain} = {
      containers.${cfg.hostName}.config = {...}: {
        networking.hostName = cfg.hostName;

        ${domain}.persist.directories = [cfg.dataDir];
        services.nginx.enable = true;
        services.nginx.virtualHosts.${cfg.hostName} = {
          # forceSSL = true;
          # enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
        services.vaultwarden.enable = true;
      };
    };
  };
}
