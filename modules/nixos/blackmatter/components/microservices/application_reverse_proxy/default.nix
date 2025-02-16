{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.microservices.application_reverse_proxy;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable application reverse proxy as a whole";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        namespace for application_reverse_proxy instance
      '';
    };

    traefik = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Traefik within the application reverse proxy";
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Traefik dynamic settings (overrides defaults if non-empty).";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.traefik;
        description = mdDoc "Traefik binary to use";
      };
    };

    consul = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Consul service within the reverse proxy setup";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.consul;
        description = mdDoc "Consul binary to use";
      };
    };

    nomad = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Nomad service within the reverse proxy setup";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.nomad;
        description = mdDoc "Nomad binary to use";
      };
    };
  };
in
{
  imports = [
    ../consul
    ../traefik
    ../nomad
  ];

  options = {
    blackmatter = {
      components = {
        microservices = {
          application_reverse_proxy = interface;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.traefik.enable) {
      blackmatter.components.microservices.traefik = {
        enable = cfg.traefik.enable;
        package = cfg.traefik.package;
        namespace = cfg.namespace;
        settings = cfg.traefik.settings;
      };
    })

    (mkIf (cfg.enable && cfg.consul.enable) {
      blackmatter.components.microservices.consul = {
        enable = cfg.consul.enable;
        package = cfg.consul.package;
        namespace = cfg.namespace;
      };
    })

    (mkIf (cfg.enable && cfg.nomad.enable) {
      blackmatter.components.microservices.nomad = {
        enable = cfg.nomad.enable;
        package = cfg.nomad.package;
        namespace = cfg.namespace;
      };
    })
  ];
}
