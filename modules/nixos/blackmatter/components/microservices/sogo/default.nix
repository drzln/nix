{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.sogo;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SOGo groupware server";
    };

    namespace = mkOption {
      type = types.str;
      default = "groupware";
      description = mdDoc ''
        Logical namespace for SOGo instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.sogo;
      description = mdDoc "SOGo package to use";
    };

    database = {
      type = mkOption {
        type = types.enum ["postgresql" "mysql"];
        default = "postgresql";
        description = mdDoc "Database type";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      name = mkOption {
        type = types.str;
        default = "sogo";
        description = mdDoc "Database name";
      };

      user = mkOption {
        type = types.str;
        default = "sogo";
        description = mdDoc "Database user";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/sogo/db-pass";
        description = mdDoc "Path to database password file";
      };
    };

    ldap = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable LDAP authentication";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "LDAP server host";
      };

      bindDN = mkOption {
        type = types.str;
        default = "cn=sogo,ou=services,dc=example,dc=com";
        description = mdDoc "LDAP bind DN";
      };

      bindPasswordFile = mkOption {
        type = types.str;
        default = "/var/lib/sogo/ldap-pass";
        description = mdDoc "Path to LDAP bind password";
      };

      baseDN = mkOption {
        type = types.str;
        default = "ou=users,dc=example,dc=com";
        description = mdDoc "LDAP base DN";
      };
    };

    mail = {
      smtp = {
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = mdDoc "SMTP server host";
        };

        port = mkOption {
          type = types.port;
          default = 587;
          description = mdDoc "SMTP server port";
        };
      };

      imap = {
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = mdDoc "IMAP server host";
        };

        port = mkOption {
          type = types.port;
          default = 993;
          description = mdDoc "IMAP server port";
        };
      };
    };

    ssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable HTTPS";
      };

      certificate = mkOption {
        type = types.path;
        default = "/var/lib/sogo/ssl/fullchain.pem";
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.path;
        default = "/var/lib/sogo/ssl/privkey.pem";
        description = mdDoc "SSL private key path";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc ''
        Additional SOGo configuration parameters
        See: https://sogo.nu/support/index.html#/preferences
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          sogo = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.sogo = {
      enable = true;
      inherit (cfg) package;

      config = {
        SOGoProfileURL = "postgresql://${cfg.database.user}@${cfg.database.host}/${cfg.database.name}";
        OCSFolderInfoURL = "postgresql://${cfg.database.user}@${cfg.database.host}/${cfg.database.name}";
        OCSSessionsFolderURL = "postgresql://${cfg.database.user}@${cfg.host}/${cfg.database.name}";

        SOGoDBServer = cfg.database.host;
        SOGoUserSources = mkIf cfg.ldap.enable [{
          type = "ldap";
          CNFieldName = "cn";
          IDFieldName = "uid";
          UIDFieldName = "uid";
          bindDN = cfg.ldap.bindDN;
          bindPassword = "ldappass"; # Will be replaced in preStart
          canAuthenticate = true;
          displayName = "LDAP";
          hostname = cfg.ldap.host;
          baseDN = cfg.ldap.baseDN;
          scope = "SUB";
          filter = "objectClass=inetOrgPerson";
        }];

        SOGoSMTPServer = "smtp://${cfg.mail.smtp.host}:${toString cfg.mail.smtp.port}";
        SOGoIMAPServer = "imap://${cfg.mail.imap.host}:${toString cfg.mail.imap.port}";

        WOPort = "127.0.0.1:20000";
      } // cfg.settings;
    };

    # Database configuration
    services.postgresql = mkIf (cfg.database.type == "postgresql") {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };

    services.mysql = mkIf (cfg.database.type == "mysql") {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
      }];
    };

    # Web server configuration
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.namespace} = {
        forceSSL = cfg.ssl.enable;
        sslCertificate = cfg.ssl.certificate;
        sslCertificateKey = cfg.ssl.certificateKey;
        locations."/SOGo" = {
          proxyPass = "http://127.0.0.1:20000/SOGo";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
          '';
        };
      };
    };

    # Secret management
    systemd.services.sogo = {
      serviceConfig = {
        EnvironmentFile = [ cfg.database.passwordFile cfg.ldap.bindPasswordFile ];
        ReadWritePaths = [ "/var/lib/sogo" ];
        ProtectHome = "read-only";
        PrivateTmp = true;
      };
      preStart = ''
        sed -i "s/ldappass/$(cat ${cfg.ldap.bindPasswordFile})/" /etc/sogo/sogo.conf
        sed -i "s/postgrespass/$(cat ${cfg.database.passwordFile})/" /etc/sogo/sogo.conf
      '';
    };

    # Firewall configuration
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = 
        if cfg.ssl.enable
        then [ 443 ]
        else [ 80 ];
    };

    # Security defaults
    services.sogo.config = {
      WONoDetach = "YES";
      WOLogFile = "/var/log/sogo/sogo.log";
      SOGoMemcachedHost = "127.0.0.1";
      SOGoPasswordChangeEnabled = "NO";
      SOGoTrustProxyAuthentication = "YES";
    };

    # Dependencies
    services.memcached.enable = true;
  };
}
