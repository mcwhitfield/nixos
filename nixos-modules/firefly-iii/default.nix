inputs @ {
  arion,
  firefly,
  ...
}: {
  imports = [
    arion.nixosModules.arion
  ];

  # https://raw.githubusercontent.com/firefly-iii/docker/main/docker-compose-importer.yml
  config.virtualisation.arion = {
    projects.firefly-iii.settings = {
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
        app = {
          pkgs,
          lib,
          ...
        }: let
          fireflyPkg = import ../../packages/firefly-iii (inputs // {inherit pkgs;});
        in {
          nixos.configuration.boot.isContainer = true;
          service = {
            command = ["${fireflyPkg}/bin/firefly-iii"];
            useHostStore = true;
            hostname = "app";
            container_name = "firefly_iii_core";
            restart = "never";
            volumes = ["firefly_iii_upload:${firefly}/html/storage/upload"];
            environment =
              import ./app.nix inputs
              // {
                FIREFLY_III_PATH = "${firefly}";
                COMPOSER_HOME = "${firefly}";
              };
            networks = ["firefly_iii"];
            ports = ["8000:8080"];
            working_dir = "${firefly}";
            tmpfs = ["/tmp"];
            # depends_on = ["db"];
          };
        };
        # db = {
        #   pkgs,
        #   lib,
        #   ...
        # }: {
        #   nixos.useSystemd = true;
        #   nixos.configuration = {
        #     services.mysql = {
        #       enable = true;
        #       package = pkgs.mariadb;
        #     };
        #     system.stateVersion = "23.11";
        #   };
        #   service = {
        #     hostname = "db";
        #     container_name = "firefly_iii_db";
        #     restart = "always";
        #     environment = import ./db.nix inputs;
        #     networks = ["firefly_iii"];
        #     volumes = ["firefly_iii_db:/var/lib/mysql"];
        #   };
        # };
        # importer.service = {
        #   image = "fireflyiii/data-importer:latest";
        #   hostname = "importer";
        #   restart = "always";
        #   container_name = "firefly_iii_importer";
        #   networks = ["firefly_iii"];
        #   ports = ["81:8080"];
        #   depends_on = ["app"];
        #   environment = import ./db.nix inputs;
        # };
        # cron.service = {
        #   image = "alpine:latest";
        #   restart = "always";
        #   container_name = "firefly_iii_cron";
        #   command = "sh -c \"echo \\\"0 3 * * * wget -qO- http://app:8080/api/v1/cron/REPLACEME\\\" | crontab - && crond -f -L /dev/stdout\"";
        #   networks = ["firefly_iii"];
        # };
      };
    };
  };
}
