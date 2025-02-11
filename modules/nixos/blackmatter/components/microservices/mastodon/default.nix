{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.mastodon;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Mastodon social networking service";
    };

    namespace = mkOption {
      type = types.str;
      default = "social";
      description = mdDoc ''
        Logical namespace for Mastodon instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.mastodon;
      description = mdDoc "Mastodon package to use";
    };

    database = {
      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "PostgreSQL host";
      };

      user = mkOption {
        type = types.str;
        default = "mastodon";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "mastodon";
        description = mdDoc "Database name";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/db-pass";
        description = mdDoc "Path to database password file";
      };
    };

    redis = {
      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Redis host";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/redis-pass";
        description = mdDoc "Path to Redis password file";
      };
    };

    smtp = {
      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "SMTP server host";
      };

      port = mkOption {
        type = types.int;
        default = 587;
        description = mdDoc "SMTP server port";
      };

      user = mkOption {
        type = types.str;
        default = "";
        description = mdDoc "SMTP username";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/smtp-pass";
        description = mdDoc "Path to SMTP password file";
      };

      from = mkOption {
        type = types.str;
        default = "mastodon@example.com";
        description = mdDoc "From address for emails";
      };
    };

    secrets = {
      secretKeyBaseFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/secret-key-base";
        description = mdDoc "Path to secret_key_base file";
      };

      otpSecretFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/otp-secret";
        description = mdDoc "Path to otp_secret file";
      };

      vapidPrivateKeyFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/vapid-private-key";
        description = mdDoc "Path to VAPID private key file";
      };

      vapidPublicKeyFile = mkOption {
        type = types.str;
        default = "/var/lib/mastodon/vapid-public-key";
        description = mdDoc "Path to VAPID public key file";
      };
    };

    web = {
      port = mkOption {
        type = types.int;
        default = 3000;
        description = mdDoc "Web server port";
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
    };

    streaming = {
      port = mkOption {
        type = types.int;
        default = 4000;
        description = mdDoc "Streaming API port";
      };
    };

    workers = mkOption {
      type = types.int;
      default = 3;
      description = mdDoc "Number of Sidekiq worker processes";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc ''
        Additional Mastodon configuration
        See: https://docs.joinmastodon.org/admin/config/
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/mastodon";
      description = mdDoc "Mastodon state directory";
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          mastodon = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.mastodon = {
      enable = true;
      inherit (cfg) package;

      configureNginx = false;
      enableUnixSocket = true;

      database = {
        host = cfg.database.host;
        name = cfg.database.name;
        user = cfg.database.user;
        passwordFile = cfg.database.passwordFile;
      };

      redis = {
        host = cfg.redis.host;
        passwordFile = cfg.redis.passwordFile;
      };

      smtp = {
        host = cfg.smtp.host;
        port = cfg.smtp.port;
        user = cfg.smtp.user;
        passwordFile = cfg.smtp.passwordFile;
        fromAddress = cfg.smtp.from;
      };

      secrets = {
        secretKeyBaseFile = cfg.secrets.secretKeyBaseFile;
        otpSecretFile = cfg.secrets.otpSecretFile;
        vapidPrivateKeyFile = cfg.secrets.vapidPrivateKeyFile;
        vapidPublicKeyFile = cfg.secrets.vapidPublicKeyFile;
      };

      settings = cfg.settings // {
        WEB_DOMAIN = mkDefault "localhost";
        LOCAL_DOMAIN = mkDefault "localhost";
      };
    };

    # Database automation
    services.postgresql = {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };

    services.redis.servers.mastodon = {
      enable = true;
      port = 6379;
      requirePassFile = cfg.redis.passwordFile;
    };

    # File storage and permissions
    systemd.services.mastodon-init = {
      description = "Mastodon directory initialization";
      wantedBy = [ "multi-user.target" ];
      before = [ "mastodon-web.service" ];
      script = ''
        mkdir -p ${cfg.stateDir}/{system,uploads,config}
        chown -R mastodon:mastodon ${cfg.stateDir}
        chmod 700 ${cfg.stateDir}/config
      '';
      serviceConfig.Type = "oneshot";
    };

    # Namespace-aware networking
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts =
        [ cfg.web.port cfg.streaming.port ]
        ++ (optional cfg.web.ssl.enable 443);
    };

    # Worker configuration
    systemd.services.mastodon-sidekiq = {
      serviceConfig.ExecStart = [
        "" # Clear existing command
        "${cfg.package}/bin/mastodon-sidekiq -c ${toString cfg.workers}"
      ];
    };

    # Security hardening
    services.nginx.virtualHosts.${cfg.settings.WEB_DOMAIN} = mkIf cfg.web.ssl.enable {
      forceSSL = true;
      sslCertificate = cfg.web.ssl.certificate;
      sslCertificateKey = cfg.web.ssl.certificateKey;
      locations."/" = {
        proxyPass = "http://unix:/run/mastodon-web/web.socket";
        proxyWebsockets = true;
      };
    };

    environment.etc."mastodon/env" = {
      text = ''
        RAILS_ENV=production
        DB_HOST=${cfg.database.host}
        REDIS_HOST=${cfg.redis.host}
      '';
      mode = "0400";
    };
  };
}
