{
  self,
  config,
  domain,
  dockerhub,
  ...
}: let
  inherit (builtins) elemAt split toString;
  service = "firefly-iii";
  inherit (self.lib) mkEnableOption mkForce mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "services" "firefly-iii"];

  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption "Enable Firefly III personal finance manager.";
    labels = mkOption {
      type = types.attrsOf types.str;
      default = {inherit service;};
    };
    user = mkOption {
      type = types.str;
      default = "firefly-iii";
      description = "User the required services will run as.";
    };
    app = {
      containerName = mkOption {
        type = types.str;
        default = "${service}-app";
        readOnly = true;
      };
      image.digest = mkOption {
        type = types.str;
        default = "fireflyiii/core@sha256:d7c82269538463abf34495650b06a35fccdffc99dbd3fa2f7fb80e2909dc5445";
        description = "A Dockerhub digest identifier for the firefly-iii core docker image.";
      };
      port = {
        host = mkOption {
          type = types.port;
          default = 8000;
        };
        container = mkOption {
          type = types.port;
          default = 8080;
          readOnly = true;
        };
      };
      dataDir = {
        host = mkOption {
          type = types.str;
          default = "/var/lib/firefly-iii/uploads";
        };
        container = mkOption {
          type = types.str;
          default = "/var/www/html/storage/upload";
          readOnly = true;
        };
      };
      settings = {
        staticCronToken = mkOption {
          type = types.strMatching ".{32}";
          default = "ZjDf3!mSsGa25P*#sq%mbeMuFi567WhL";
        };
        siteOwner = mkOption {
          type = types.strMatching ".*@.*";
        };
        defaultLanguage = mkOption {
          type = types.enum [
            "bg_BG"
            "ca_ES"
            "cs_CZ"
            "da_DK"
            "de_DE"
            "el_GR"
            "en_GB"
            "en_US"
            "es_ES"
            "fi_FI"
            "fr_FR"
            "hu_HU"
            "id_ID"
            "it_IT"
            "ja_JP"
            "ko_KR"
            "nb_NO"
            "nl_NL"
            "nn_NO"
            "pl_PL"
            "pt_BR"
            "pt_PT"
            "ro_RO"
            "ru_RU"
            "sk_SK"
            "sl_SI"
            "sv_SE"
            "th_TH"
            "tr_TR"
            "uk_UA"
            "vi_VN"
            "zh_CN"
            "zh_TW"
          ];
          default = elemAt (split "\\." config.i18n.defaultLocale) 0;
        };
      };
      extraEnvironmentVars = mkOption {
        type = types.attrs;
        default = {};
      };
    };
    db = {
      containerName = mkOption {
        type = types.str;
        default = "${service}-db";
        readOnly = true;
      };
      image.digest = mkOption {
        type = types.str;
        default = "mariadb@sha256:15bd5a1891a297e2b1ad33c5fdc40846033e064a152d4cf06841bb19bf8ca46c";
        description = "A Dockerhub digest identifier for the firefly-iii database docker image.";
      };
      dbName = mkOption {
        type = types.str;
        default = "firefly";
      };
      port = {
        container = mkOption {
          type = types.port;
          default = 3306;
          readOnly = true;
        };
      };
      dataDir = {
        host = mkOption {
          type = types.str;
          default = "/var/lib/firefly-iii/db";
        };
        container = mkOption {
          type = types.str;
          default = "/var/lib/mysql";
          readOnly = true;
        };
      };
      extraEnvironmentVars = mkOption {
        type = types.attrs;
        default = {};
      };
    };
    importer = {
      containerName = mkOption {
        type = types.str;
        default = "${service}-importer";
        readOnly = true;
      };
      image.digest = mkOption {
        type = types.str;
        default = "fireflyiii/data-importer@sha256:92ae117f4dcf0dd9699f3e4dd589664b16137c7c2c7b30fd24b43f676b8c20f2";
        description = "A Dockerhub digest identifier for the firefly-iii data importer docker image.";
      };
      port = {
        host = mkOption {
          type = types.port;
          default = 8001;
        };
        container = mkOption {
          type = types.port;
          default = 8080;
          readOnly = true;
        };
      };
      extraEnvironmentVars = mkOption {
        type = types.attrs;
        default = {};
      };
    };
    cron = {
      containerName = mkOption {
        type = types.str;
        default = "${service}-cron";
        readOnly = true;
      };
      image.digest = mkOption {
        type = types.str;
        default = "alpine@sha256:13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd";
        description = "A Dockerhub digest identifier for the firefly-iii cron docker image.";
      };
      extraEnvironmentVars = mkOption {
        type = types.attrs;
        default = {};
      };
      schedule = mkOption {
        type = types.str;
        default = "0 3 * * *";
      };
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.containers.firefly-iii.config = {config, ...}: {
      ${domain} = {
        secrets = {
          "firefly-iii-app".owner = cfg.user;
          "firefly-iii-db".owner = cfg.user;
          "firefly-iii-importer".owner = cfg.user;
        };
        persist.directories = [
          cfg.app.dataDir.host
          cfg.db.dataDir.host
        ];
      };
      # https://raw.githubusercontent.com/firefly-iii/docker/main/docker-compose-importer.yml
      virtualisation.oci-containers.containers = mkIf cfg.enable {
        ${cfg.app.containerName} = with {c = cfg.app;}; {
          image = c.image.digest;
          labels = cfg.labels;
          hostname = c.containerName;
          volumes = ["${c.dataDir.host}:${c.dataDir.container}"];
          environmentFiles = [config.age.secrets."firefly-iii-app".path];
          ports = ["${toString c.port.host}:${toString c.port.container}"];
          dependsOn = [cfg.db.containerName];
          user = cfg.user;
        };
        ${cfg.db.containerName} = with {c = cfg.db;}; {
          image = c.image.digest;
          labels = cfg.labels;
          hostname = c.containerName;
          volumes = ["${c.dataDir.host}:${c.dataDir.container}"];
          environmentFiles = [config.age.secrets."firefly-iii-db".path];
          user = cfg.user;
        };
        ${cfg.importer.containerName} = with {c = cfg.importer;}; {
          image = c.image.digest;
          labels = cfg.labels;
          hostname = c.containerName;
          ports = ["${toString c.port.host}:${toString c.port.container}"];
          dependsOn = [cfg.app.containerName];
          environmentFiles = [config.age.secrets."firefly-iii-importer".path];
          user = cfg.user;
        };
        ${cfg.cron.containerName} = with {c = cfg.cron;}; {
          image = c.image.digest;
          labels = cfg.labels;
          environment = c.extraEnvironmentVars;
          user = cfg.user;
          cmd = let
            host = config.virtualisation.oci-containers.containers.${cfg.app.containerName}.hostname;
            port = toString cfg.app.port.container;
            token = cfg.app.settings.staticCronToken;
            url = "http://${host}:${port}/api/v1/cron/${token}";
          in [
            "sh"
            "-c"
            "echo \"${c.schedule} wget -qO- ${url}\" | crontab - && crond -f -L /dev/stdout"
          ];
        };
      };
      firewall.interfaces."podman+".allowedUDPPorts = [53];
      systemd.services = {
        podman-firefly-iii-importer.serviceConfig.TimeoutStopSec = mkForce 5;
      };
      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
      };
      users.groups.${cfg.user} = {};
    };
  };
}
