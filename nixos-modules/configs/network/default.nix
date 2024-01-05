{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkDefault mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "network"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Configure a standard networking setup for hosts on ${domain}.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
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
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
  };
}
