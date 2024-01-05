{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkOption mkIf types;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "security" "acme"];
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = config.services.nginx.enable;
      description = ''
        Enable SSL Cert management via ACME/Let's Encrypt.
      '';
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain} = {
      secrets."namecheap-creds".owner = config.security.acme.certs.${domain}.group;
      persist.directories = [config.security.acme.certs.${domain}.directory];
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "mark@${domain}";
      certs.${domain} = {
        domain = "*.${domain}";
        dnsProvider = "namecheap";
        credentialsFile = config.age.secrets."namecheap-creds".path;
      };
    };
  };
}
