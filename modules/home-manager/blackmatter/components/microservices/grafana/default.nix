{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.grafana;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Grafana for dashboard visualization.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Namespace for the Grafana instance.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.grafana;
      description = mdDoc "Grafana package to use for visualization.";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/grafana/grafana.ini";
      description = mdDoc "Path to the Grafana configuration file.";
    };

    extraOptions = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc "Extra configuration options for Grafana, merged into its configuration.";
    };
  };
in
{
  options = {
    blackmatter.components.microservices.grafana = interface;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.grafana = {
        enable = true;
        package = cfg.package;
        configFile = cfg.configFile;
        extraConfig = cfg.extraOptions;
      };
    })
  ];
}

