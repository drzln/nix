{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.archon-user-service;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the user-level Nginx server service.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Namespace for the user-level Nginx instance.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nginx;
      description = mdDoc "Nginx package to use for serving HTTP.";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/nginx/nginx.conf";
      description = mdDoc "Path to the Nginx configuration file.";
    };
  };
in
{
  options.blackmatter.components.microservices.archon-user-service = interface;

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Define a systemd user service for Nginx
      systemd.user.services.archon-user-service = {
        description = "User-level Nginx server";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          # Run Nginx in the foreground (daemon off) with the specified config file.
          ExecStart = "${cfg.package}/bin/nginx -c ${cfg.configFile} -g 'daemon off;'";
          Restart = "always";
        };
        install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ];
}

