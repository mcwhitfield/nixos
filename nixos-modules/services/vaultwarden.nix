{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "services" "vaultwarden"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable Vaultwarden (self-hosted FOSS Bitwarden implementation) password manager service.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain}.persist.directories = [
      "/var/lib/bitwarden_rs"
    ];
    services.vaultwarden = {
      enable = true;
    };
  };
}
