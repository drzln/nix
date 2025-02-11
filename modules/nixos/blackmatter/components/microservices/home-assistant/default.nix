{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.home_assistant;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Home Assistant smart home platform";
    };

    namespace = mkOption {
      type = types.str;
      default = "smart-home";
      description = mdDoc ''
        Logical namespace for Home Assistant instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.home-assistant;
      description = mdDoc "Home Assistant package to use";
    };

    configDir = mkOption {
      type = types.str;
      default = "/var/lib/homeassistant";
      description = mdDoc "Configuration directory path";
    };

    database = {
      type = mkOption {
        type = types.enum ["sqlite" "postgresql" "mysql"];
        default = "sqlite";
        description = mdDoc "Database type";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      user = mkOption {
        type = types.str;
        default = "homeassistant";
        description = mdDoc "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "homeassistant";
        description = mdDoc "Database name";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/homeassistant/db-pass";
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
        default = "/var/lib/homeassistant/fullchain.pem";
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.path;
        default = "/var/lib/homeassistant/privkey.pem";
        description = mdDoc "SSL private key path";
      };
    };

    iot = {
      zwave = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Z-Wave support";
      };

      zigbee = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Zigbee support";
      };

      usb = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable USB device access";
      };

      gpio = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Raspberry Pi GPIO access";
      };
    };

    components = mkOption {
      type = types.listOf types.str;
      default = [];
      description = mdDoc "List of enabled components";
    };

    addons = mkOption {
      type = types.listOf types.package;
      default = [];
      description = mdDoc "Custom components/addons to install";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable automatic updates";
    };

    secretsFile = mkOption {
      type = types.str;
      default = "${cfg.configDir}/secrets.yaml";
      description = mdDoc "Path to secrets.yaml file";
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          home_assistant = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      inherit (cfg) package configDir;

      config = {
        default_config = {};
        http = {
          server_port = 8123;
          ssl_certificate = mkIf cfg.ssl.enable cfg.ssl.certificate;
          ssl_key = mkIf cfg.ssl.enable cfg.ssl.certificateKey;
        };
        recorder = mkIf (cfg.database.type != "sqlite") {
          db_url = 
            if cfg.database.type == "postgresql"
            then "postgresql://${cfg.database.user}:@${cfg.database.host}/${cfg.database.name}"
            else "mysql://${cfg.database.user}:@${cfg.database.host}/${cfg.database.name}?charset=utf8mb4";
        };
      };

      extraComponents = cfg.components;
      extraPackages = ps: cfg.addons;
    };

    # Database automation
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

    # Hardware access
    hardware.zwave.enable = cfg.iot.zwave;
    services.udev.extraRules = optionalString cfg.iot.usb ''
      SUBSYSTEM=="tty", TAG+="homeassistant"
    '' + optionalString cfg.iot.zigbee ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", TAG+="homeassistant"
    '';

    # Security defaults
    systemd.services.home-assistant = {
      serviceConfig = {
        EnvironmentFile = cfg.secretsFile;
        ReadWritePaths = [ cfg.configDir ];
        DeviceAllow = [ 
          "char-alsa rw"
          "char-input rw"
        ] ++ optional cfg.iot.gpio "char-gpio rw";
      };
    };

    # Namespace networking
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = 
        if cfg.ssl.enable
        then [ 443 8123 ]
        else [ 80 8123 ];
    };

    # Secret management
    environment.etc."homeassistant/secrets.yaml" = {
      source = cfg.secretsFile;
      mode = "0400";
    };

    # Auto-update service
    systemd.services.home-assistant-update = mkIf cfg.autoUpdate {
      description = "Home Assistant Update Service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.home-assistant}/bin/hass --script check_config";
      };
      startAt = "daily";
    };
  };
}
