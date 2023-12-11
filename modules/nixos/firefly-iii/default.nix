inputs @ {
  dockerhub,
  arion,
  ...
}: {
  imports = [
    arion.nixosModules.arion
  ];

  # https://raw.githubusercontent.com/firefly-iii/docker/main/docker-compose-importer.yml
  config.virtualisation.arion = {
    backend = "docker";
    projects.firefly-iii.settings = with dockerhub; {
      docker-compose.volumes = {
        firefly_iii_upload = {};
        firefly_iii_db = {};
      };
      networks = {
        firefly_iii = {
          driver = "bridge";
        };
      };
      services = {
        app.service = {
          image = "fireflyiii/core:${fireflyiii.core.latest}";
          hostname = "app";
          container_name = "firefly_iii_core";
          restart = "always";
          volumes = ["firefly_iii_upload:/var/www/html/storage/upload"];
          environment = import ./app.nix inputs;
          networks = ["firefly_iii"];
          ports = ["80:8080"];
          depends_on = ["db"];
        };
        db.service = {
          image = "mariadb:${_.mariadb.latest}";
          hostname = "db";
          container_name = "firefly_iii_db";
          restart = "always";
          environment = import ./db.nix inputs;
          networks = ["firefly_iii"];
          volumes = ["firefly_iii_db:/var/lib/mysql"];
        };
        importer.service = {
          image = "fireflyiii/data-importer:${fireflyiii.data-importer.latest}";
          hostname = "importer";
          restart = "always";
          container_name = "firefly_iii_importer";
          networks = ["firefly_iii"];
          ports = ["81:8080"];
          depends_on = ["app"];
          environment = import ./db.nix inputs;
        };
        cron.service = {
          image = "alpine:${_.alpine.latest}";
          restart = "always";
          container_name = "firefly_iii_cron";
          command = "sh -c \"echo \\\"0 3 * * * wget -qO- http://app:8080/api/v1/cron/REPLACEME\\\" | crontab - && crond -f -L /dev/stdout\"";
          networks = ["firefly_iii"];
        };
      };
    };
  };
}
