{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "ssh"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Configure a standard SSH setup for hosts on ${domain}.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    security.pam.enableSSHAgentAuth = true;
    programs.ssh.startAgent = true;
    services.openssh = {
      enable = true;
      startWhenNeeded = false;
      settings = {
        PasswordAuthentication = false;
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
      };
      allowSFTP = false;
      extraConfig = ''
        AllowTcpForwarding yes
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
  };
}
