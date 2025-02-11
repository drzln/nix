{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.influxdb;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable InfluxDB for time-series data storage.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Namespace for the InfluxDB instance.
        This is for logical grouping and identification.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.influxdb;
      description = mdDoc "InfluxDB package to use.";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/influxdb/influxdb.conf";
      description = mdDoc "Path to the InfluxDB configuration file.";
    };

    extraOptions = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc "Extra configuration options for InfluxDB, merged into its configuration.";
    };
  };
in
{
  options = {
    blackmatter.components.microservices.influxdb = interface;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.influxdb = {
        enable = true;
        package = cfg.package;
        configFile = cfg.configFile;
        extraOptions = cfg.extraOptions;
      };
    })
  ];
}

