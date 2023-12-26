{config, ...}: let
  cfg = config.services.firefly-iii;
in {
  MARIADB_USER = "firefly";
  MARIADB_DATABASE = cfg.db.dbName;
}
