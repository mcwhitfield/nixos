{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkDefaultEnabled mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "network"];
in {
  options = setAttrByPath configKey {
    enable = mkDefaultEnabled ''
      Configure a standard networking setup for hosts on ${domain}.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    networking = {
      domain = domain;
      firewall = {
        checkReversePath = "loose";
        trustedInterfaces = ["tailscale0"];
        allowedUDPPorts = [config.services.tailscale.port];
        # https://github.com/NixOS/nixpkgs/issues/226365
        interfaces = let
          hasContainers = config.virtualisation.oci-containers.containers != {};
        in
          mkIf hasContainers {
            "podman+".allowedUDPPorts = [53];
          };
      };
      networkmanager.enable = true;
    };

    services = {
      openssh = {
        enable = true;
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
      tailscale.enable = true;
    };
  };
}
