{ config, pkgs, lib, ... }:
{
  services.firefox-syncserver = {
    database.createLocally = true;
    enable = true;
    secrets = lib.getSecret config ./.;
    settings.tokenserver.enabled = true;
    singleNode = {
      enable = true;
      hostname = config.networking.hostName;
    };
  };
  services.mysql.package = pkgs.mysql;
}
