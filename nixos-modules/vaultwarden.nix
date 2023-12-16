{config, ...}: {
  environment.persistence."/persist".directories = [
    "/var/lib/bitwarden_rs"
  ];
  services.vaultwarden = {
    enable = true;
  };
}
