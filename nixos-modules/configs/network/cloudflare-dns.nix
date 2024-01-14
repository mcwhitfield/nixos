{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "network" "resolved"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable systemd-resolved and use 1.1.1.1 for DNS.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

    services.resolved = {
      enable = true;
      domains = ["~."];
      fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    };
  };
}
