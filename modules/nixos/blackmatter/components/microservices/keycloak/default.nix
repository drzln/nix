{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.keycloak;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Keycloak identity management service";
    };

    namespace = mkOption {
      type = types.str;
      default = "identity";
      description = mdDoc ''
        Logical namespace for Keycloak instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.keycloak;
      description = mdDoc "Keycloak package to use";
    };

    database = {
      type = mkOption {
        type = types.enum [ "postgresql" "mysql" "h2" ];
        default = "postgresql";
        description = mdDoc "Database type";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      username = mkOption {
        type = types.str;
        default = "keycloak";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "keycloak";
        description = mdDoc "Database name";
      };
    };

    ssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable SSL/TLS encryption";
      };

      certificate = mkOption {
        type = types.path;
        default = null;
        description = mdDoc "Path to SSL certificate";
      };

      certificateKey = mkOption {
        type = types.path;
        default = null;
        description = mdDoc "Path to SSL certificate key";
      };
    };

    theme = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = mdDoc "Custom theme package";
      };
    };

    admin = {
      user = mkOption {
        type = types.str;
        default = "admin";
        description = mdDoc "Initial admin username";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/keycloak/admin-password";
        description = mdDoc "Path to file containing admin password";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc ''
        Additional Keycloak configuration properties
        See: https://www.keycloak.org/server/all-config
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          keycloak = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.keycloak = {
      enable = true;
      inherit (cfg) package settings;

      database = {
        type = cfg.database.type;
        host = cfg.database.host;
        username = cfg.database.username;
        database = cfg.database.name;
      };

      sslCertificate = mkIf cfg.ssl.enable cfg.ssl.certificate;
      sslCertificateKey = mkIf cfg.ssl.enable cfg.ssl.certificateKey;

      initialAdminCredentials = {
        username = cfg.admin.user;
        passwordFile = cfg.admin.passwordFile;
      };

      themes = mkIf (cfg.theme.package != null) {
        inherit (cfg.theme) package;
      };
    };

    # Database automation
    services.postgresql = mkIf (cfg.database.type == "postgresql") {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.username;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };

    services.mysql = mkIf (cfg.database.type == "mysql") {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.username;
        ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
      }];
    };

    # Security defaults
    services.keycloak.settings = {
      http-enabled = mkDefault (!cfg.ssl.enable);
      hostname-strict = mkDefault true;
      proxy = "edge";
    };

    # Namespace networking
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts =
        if cfg.ssl.enable
        then [ 8443 ]
        else [ 8080 ];
    };

    # Theme management
    systemd.services.keycloak.preStart = mkIf (cfg.theme.package != null) ''
      mkdir -p /var/lib/keycloak/themes
      cp -r ${cfg.theme.package}/* /var/lib/keycloak/themes/
    '';
  };
}
