{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.envoy_consul;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Envoy and Consul integration.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = "Namespace for the Envoy and Consul instance.";
    };

    envoy = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Envoy service.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.envoy;
        description = "Envoy package to use.";
      };
      config = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Custom Envoy configuration settings.";
      };
    };

    consul = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Consul service.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.consul;
        description = "Consul package to use.";
      };
      config = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Custom Consul configuration settings.";
      };
    };
  };
in
{
  options = {
    blackmatter.components.microservices.envoy_consul = interface;
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.consul.enable) {
      services.consul = {
        enable = true;
        package = cfg.consul.package;
        extraConfig = cfg.consul.config;
      };
    })

    (mkIf (cfg.enable && cfg.envoy.enable) {
      services.envoy = {
        enable = true;
        package = cfg.envoy.package;
        config = cfg.envoy.config;
      };
    })
  ];
}

