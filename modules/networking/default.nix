{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkDefault mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configure a standard networking setup for hosts on ${domain}.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    networking = {
      domain = domain;
      firewall.interfaces = let
        hasContainers = config.virtualisation.oci-containers.containers != {};
      in
        mkIf hasContainers {
          "podman+".allowedUDPPorts = [53];
        };
      networkmanager.enable = mkDefault true;
    };

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
