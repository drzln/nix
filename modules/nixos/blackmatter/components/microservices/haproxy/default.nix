{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.haproxy;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the HAProxy load balancer.";
    };

    config-file = mkOption {
      type = types.package;
    };

    host = mkOption {
      type = types.str;
      default = "haproxy";
    };

    domain = mkOption {
      type = types.str;
    };

    local-ip = mkOption {
      type = types.str;
    };

    dns-server = mkOption {
      type = types.str;
    };
  };
in
{
  options.blackmatter.components.microservices.haproxy = interface;

  config = mkMerge [
    (mkIf cfg.enable {
      services.dnsmasq.enable = true;
      services.dnsmasq.resolveLocalQueries = true;
      services.dnsmasq.settings.address = [
        "/${cfg.host}.${cfg.domain}/${cfg.local-ip}"
      ];
      services.dnsmasq.settings.server = [
        cfg.dns-server
      ];
      services.haproxy = {
        enable = true;
        config = builtins.readFile cfg.config-file;
      };
    })
  ];
}

