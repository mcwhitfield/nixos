{
  config,
  domain,
  ...
}: let
  headscaleDomain = "headscale.${domain}";
in {
  environment = {
    persistence."/persist".directories = ["/var/lib/headscale"];
    systemPackages = [config.services.headscale.package];
  };
  networking = {
    domain = domain;
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    networkmanager.enable = true;
  };

  services = {
    nginx.virtualHosts.${headscaleDomain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
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
  # https://github.com/juanfont/headscale/issues/1574
  # Reportedly fixed at HEAD but I'm not bothering with that. Can probably be removed
  # in a couple months or so as of 2023/12
  systemd.services.headscale.serviceConfig.TimeoutStopSec = 5;
}
