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
    hostName = mkOption {
      type = types.str;
      default = "vaultwarden";
      description = ''
        Hostname of the container (locally, on the privateNetwork, and on the tailnet).
      '';
    };
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
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain} = {
      containers.${cfg.hostName}.config = {...}: {
        ${domain} = {
          persist.directories = [cfg.dataDir];
          services.reverseProxy.upstream.port = cfg.port;
        };
        services.vaultwarden.enable = true;
      };
    };
  };
}
