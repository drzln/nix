{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.matomo;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Matomo web analytics service";
    };

    namespace = mkOption {
      type = types.str;
      default = "analytics";
      description = mdDoc ''
        Logical namespace for Matomo instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.matomo;
      description = mdDoc "Matomo package to use";
    };

    database = {
      type = mkOption {
        type = types.enum ["mysql" "postgresql"];
        default = "mysql";
        description = mdDoc "Database type";
      };
      
      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      user = mkOption {
        type = types.str;
        default = "matomo";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "matomo";
        description = mdDoc "Database name";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/matomo/db-pass";
        description = mdDoc "Path to database password file";
      };
    };

    ssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable HTTPS";
      };

      certificate = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc "SSL private key path";
      };
    };

    phpSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc "PHP-FPM configuration options";
    };

    enableArchiveCron = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable automatic report archiving";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/matomo";
      description = mdDoc "Matomo data directory";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc ''
        Matomo configuration.php settings
        See: https://matomo.org/docs/configuration-file/
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          matomo = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.matomo = {
      enable = true;
      inherit (cfg) package phpSettings;

      database = {
        type = cfg.database.type;
        host = cfg.database.host;
        username = cfg.database.user;
        passwordFile = cfg.database.passwordFile;
        name = cfg.database.name;
      };

      settings = cfg.settings // {
        General = {
          salt = "$(head -c1M /dev/urandom | sha256sum | cut -d' ' -f1)";
          trusted_hosts = ["${cfg.namespace}"];
        };
      };

      nginx = {
        enable = true;
        forceSSL = cfg.ssl.enable;
        sslCertificate = mkIf cfg.ssl.enable cfg.ssl.certificate;
        sslCertificateKey = mkIf cfg.ssl.enable cfg.ssl.certificateKey;
      };

      archiveReports.enable = cfg.enableArchiveCron;
    };

    # Database automation
    services.mysql = mkIf (cfg.database.type == "mysql") {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
      }];
    };

    services.postgresql = mkIf (cfg.database.type == "postgresql") {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };

    # File storage setup
    systemd.services.matomo-setup = {
      description = "Matomo directory setup";
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-matomo.service" ];
      script = ''
        mkdir -p ${cfg.stateDir}/{tmp,config,plugins}
        chown -R matomo:matomo ${cfg.stateDir}
        chmod 700 ${cfg.stateDir}/config
      '';
      serviceConfig.Type = "oneshot";
    };

    # Namespace-aware networking
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = 
        if cfg.ssl.enable
        then [ 443 ]
        else [ 80 ];
    };

    # Security hardening
    services.phpfpm.pools.matomo.settings = {
      "php_admin_value[open_basedir]" = "${cfg.stateDir}:/run/phpfpm";
      "php_admin_value[upload_tmp_dir]" = "${cfg.stateDir}/tmp";
      "php_admin_value[session.save_path]" = "${cfg.stateDir}/tmp";
    };
  };
}
