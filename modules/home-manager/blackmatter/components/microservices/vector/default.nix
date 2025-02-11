{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.vector;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Vector for data collection and routing.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Namespace for the Vector service instance.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.vector;
      description = mdDoc "Vector package to use for the data pipeline.";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/vector/vector.toml";
      description = mdDoc "Path to the Vector configuration file.";
    };

    extraOptions = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = mdDoc "Extra command line options for the Vector service.";
    };
  };
in
{
  options = {
    blackmatter.components.microservices.vector = interface;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # This section assumes you have defined a NixOS module for the vector service,
      # for example, as services.vector. If one doesn't exist, you can create one by
      # writing a custom systemd service that uses cfg.package and cfg.configFile.
      services.vector = {
        enable = true;
        package = cfg.package;
        configFile = cfg.configFile;
        extraOptions = cfg.extraOptions;
        namespace = cfg.namespace;
      };
    })
  ];
}

