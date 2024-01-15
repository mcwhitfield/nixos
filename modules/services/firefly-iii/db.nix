{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf;
  inherit (self.lib.attrsets) attrByPath;
  configKey = [domain "services" "firefly-iii"];

  cfg = attrByPath configKey {} config;
in
  mkIf cfg.enable {
    virtualisation.oci-containers.containers.${cfg.db.containerName}.environment = {
      MARIADB_USER = "firefly";
      MARIADB_DATABASE = cfg.db.dbName;
    };
  }
