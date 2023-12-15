{config, ...}: {
  environment.persistence."/persistent/${config.networking.hostName}".directories = [
    "/var/lib/bitwarden_rs"
  ];
  services.vaultwarden = {
    enable = true;
  };
}
