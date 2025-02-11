{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.gitea;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Gitea git service";
    };

    namespace = mkOption {
      type = types.str;
      default = "git";
      description = mdDoc ''
        Logical namespace for Gitea instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.gitea;
      description = mdDoc "Gitea package to use";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/gitea";
      description = mdDoc "Gitea state directory";
    };

    database = {
      type = mkOption {
        type = types.enum [ "sqlite3" "mysql" "postgres" ];
        default = "sqlite3";
        description = mdDoc "Database type";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      user = mkOption {
        type = types.str;
        default = "gitea";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "gitea";
        description = mdDoc "Database name";
      };
    };

    lfs = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Git LFS support";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc ''
        Configuration settings that map to Gitea's app.ini configuration.
        See https://docs.gitea.io/en-us/config-cheat-sheet/
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          gitea = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.gitea = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) stateDir;
      database = cfg.database;
      lfs.enable = cfg.lfs.enable;
      settings = cfg.settings;
    };

    # Default configuration if not overridden
    services.gitea.settings = {
      server = mkDefault {
        DOMAIN = "localhost";
        HTTP_PORT = 3000;
        ROOT_URL = "http://localhost:3000/";
      };
      session.COOKIE_SECURE = mkDefault true;
    };

    # Namespace-aware networking
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = [ 3000 2222 ]; # Web interface + SSH
    };

    # Database automation for common setups
    services.mysql = mkIf (cfg.database.type == "mysql") {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
      }];
    };

    services.postgresql = mkIf (cfg.database.type == "postgres") {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };
  };
}
