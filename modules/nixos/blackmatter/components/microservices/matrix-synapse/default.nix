{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.matrix_synapse;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Matrix Synapse chat server";
    };

    namespace = mkOption {
      type = types.str;
      default = "chat";
      description = mdDoc ''
        Logical namespace for Matrix instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.matrix-synapse;
      description = mdDoc "Matrix Synapse package to use";
    };

    server_name = mkOption {
      type = types.str;
      example = "example.com";
      description = mdDoc "Domain name of the Matrix server";
    };

    database = {
      type = mkOption {
        type = types.enum ["postgresql"];
        default = "postgresql";
        description = mdDoc "Database type (currently only PostgreSQL supported)";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      user = mkOption {
        type = types.str;
        default = "synapse";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "synapse";
        description = mdDoc "Database name";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/matrix-synapse/db-pass";
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
        type = types.path;
        default = "/var/lib/matrix-synapse/ssl/fullchain.pem";
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.path;
        default = "/var/lib/matrix-synapse/ssl/privkey.pem";
        description = mdDoc "SSL private key path";
      };
    };

    federation = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable federation with other Matrix homeservers";
      };

      well_known = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Generate .well-known files for federation";
      };
    };

    secrets = {
      signingKeyFile = mkOption {
        type = types.str;
        default = "/var/lib/matrix-synapse/signing.key";
        description = mdDoc "Path to signing key file";
      };

      registrationSharedSecretFile = mkOption {
        type = types.str;
        default = "/var/lib/matrix-synapse/registration-secret";
        description = mdDoc "Path to registration shared secret";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc ''
        Additional homeserver.yaml configuration
        See: https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          matrix_synapse = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      inherit (cfg) package server_name;

      dataDir = "/var/lib/matrix-synapse";
      registration_shared_secret_path = cfg.secrets.registrationSharedSecretFile;
      tls_certificate_path = mkIf cfg.ssl.enable cfg.ssl.certificate;
      tls_private_key_path = mkIf cfg.ssl.enable cfg.ssl.certificateKey;

      settings = cfg.settings // {
        database = {
          name = "psycopg2";
          args = {
            user = cfg.database.user;
            password = "@@DB_PASSWORD@@";
            database = cfg.database.name;
            host = cfg.database.host;
            cp_min = 5;
            cp_max = 10;
          };
        };

        listeners = [
          {
            port = 8008;
            bind_addresses = ["::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
                compress = true;
              }
            ];
          }
        ];

        enable_registration = false;
        allow_guest_access = false;
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

    # Federation well-known files
    services.nginx.virtualHosts.${cfg.server_name} = mkIf cfg.federation.well_known {
      locations."/.well-known/matrix/server".extraConfig = ''
        add_header Content-Type application/json;
        return 200 '{"m.server": "${cfg.server_name}:443"}';
      '';
      locations."/.well-known/matrix/client".extraConfig = ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.homeserver": {"base_url": "https://${cfg.server_name}"}}';
      '';
    };

    # Reverse proxy configuration
    services.nginx.virtualHosts.${cfg.server_name} = mkIf cfg.ssl.enable {
      forceSSL = true;
      sslCertificate = cfg.ssl.certificate;
      sslCertificateKey = cfg.ssl.certificateKey;
      locations."/" = {
        proxyPass = "http://localhost:8008";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    # Security hardening
    systemd.services.matrix-synapse = {
      serviceConfig = {
        EnvironmentFile = cfg.database.passwordFile;
        ReadWritePaths = [ "/var/lib/matrix-synapse" ];
        ProtectHome = "read-only";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
      preStart = ''
        sed -i "s/@@DB_PASSWORD@@/$(cat $CREDENTIALS_DIRECTORY/db-pass)/" \
          /var/lib/matrix-synapse/homeserver.yaml
      '';
    };

    # Namespace-aware firewall
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = [ 80 443 8448 ];
      allowedUDPPorts = [ 8448 ];
    };

    # Security defaults
    services.matrix-synapse.settings = {
      limit_remote_rooms = {
        enabled = true;
        complexity = 1.0;
      };
      federation_ip_range_blacklist = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "169.254.0.0/16"
        "fe80::/10"
        "fc00::/7"
      ];
      rc_login = {
        address = {
          per_second = 0.17;
          burst_count = 3;
        };
        account = {
          per_second = 0.17;
          burst_count = 3;
        };
      };
    };
  };
}
