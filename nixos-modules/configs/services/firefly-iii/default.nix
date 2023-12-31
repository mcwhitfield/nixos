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
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "services" "firefly-iii"];

  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption "Enable Firefly III personal finance manager.";
    labels = mkOption {
      type = types.attrsOf types.str;
      default = {inherit service;};
    };
    app = {
      containerName = mkOption {
        type = types.str;
        default = "${service}-app";
        readOnly = true;
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
      secrets.source = mkOption {type = types.path;};
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
      secrets.source = mkOption {type = types.path;};
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
      secrets.source = mkOption {type = types.path;};
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

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    ${domain}.containers.firefly-iii.config = inputs @ {config, ...}: let
      ctx = inputs // {inherit cfg;};
    in {
      # https://raw.githubusercontent.com/firefly-iii/docker/main/docker-compose-importer.yml
      virtualisation.oci-containers.containers = mkIf cfg.enable {
        ${cfg.app.containerName} = with {c = cfg.app;}; {
          image = dockerhub.fireflyiii.core.latest;
          labels = cfg.labels;
          hostname = c.containerName;
          volumes = ["${c.dataDir.host}:${c.dataDir.container}"];
          environment = import ./_app.nix ctx // c.extraEnvironmentVars;
          environmentFiles = [c.secrets.source];
          ports = ["${toString c.port.host}:${toString c.port.container}"];
          dependsOn = [cfg.db.containerName];
        };
        ${cfg.db.containerName} = with {c = cfg.db;}; {
          image = dockerhub._.mariadb.latest;
          labels = cfg.labels;
          hostname = c.containerName;
          volumes = ["${c.dataDir.host}:${c.dataDir.container}"];
          environment = import ./_db.nix ctx // c.extraEnvironmentVars;
          environmentFiles = [c.secrets.source];
        };
        ${cfg.importer.containerName} = with {c = cfg.importer;}; {
          image = dockerhub.fireflyiii.data-importer.latest;
          labels = cfg.labels;
          hostname = c.containerName;
          ports = ["${toString c.port.host}:${toString c.port.container}"];
          dependsOn = [cfg.app.containerName];
          environment = import ./_importer.nix ctx // c.extraEnvironmentVars;
          environmentFiles = [c.secrets.source];
        };
        ${cfg.cron.containerName} = with {c = cfg.cron;}; {
          image = dockerhub._.alpine.latest;
          labels = cfg.labels;
          environment = c.extraEnvironmentVars;
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
      ${domain}.persist.directories = [
        cfg.app.dataDir.host
        cfg.db.dataDir.host
      ];
      systemd.services = {
        podman-firefly-iii-importer.serviceConfig.TimeoutStopSec = mkForce 5;
      };
    };
  };
}
