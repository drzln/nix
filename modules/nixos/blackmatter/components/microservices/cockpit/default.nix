{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.cockpit;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Cockpit web-based server management";
    };

    namespace = mkOption {
      type = types.str;
      default = "management";
      description = mdDoc ''
        Logical namespace for Cockpit instance
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cockpit;
      description = mdDoc "Cockpit package to use";
    };

    port = mkOption {
      type = types.port;
      default = 9090;
      description = mdDoc "Web interface port";
    };

    ssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable HTTPS";
      };

      certificate = mkOption {
        type = types.path;
        default = "/var/lib/cockpit/ssl/fullchain.pem";
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.path;
        default = "/var/lib/cockpit/ssl/privkey.pem";
        description = mdDoc "SSL private key path";
      };
    };

    firewall = {
      allowedIPs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = mdDoc "IP ranges allowed to access Cockpit";
      };
    };

    features = {
      docker = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Docker container management";
      };

      storage = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable storage management";
      };

      networking = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable network configuration";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc ''
        Additional cockpit.conf settings
        See: https://cockpit-project.org/guide/latest/cockpit.conf.5.html
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          cockpit = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      inherit (cfg) port settings;
      package = cfg.package;

      settings = cfg.settings // {
        WebService = {
          Origins = "https://${cfg.namespace} wss://${cfg.namespace}";
          ProtocolHeader = mkIf cfg.ssl.enable "X-Forwarded-Proto";
          AllowUnencrypted = mkDefault (!cfg.ssl.enable);
        };
      };
    };

    # SSL configuration
    security.acme.certs."${cfg.namespace}" = mkIf cfg.ssl.enable {
      inherit (cfg.ssl) certificate certificateKey;
      reloadServices = [ "cockpit.service" ];
    };

    # Firewall configuration
    networking.firewall.interfaces."${cfg.namespace}" = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    # Feature dependencies
    virtualisation.docker.enable = mkIf cfg.features.docker true;
    services.udisks2.enable = mkIf cfg.features.storage true;
    networking.networkmanager.enable = mkIf cfg.features.networking true;

    # Access control
    services.cockpit.settings = {
      SessionOwner = {
        Admin = mkDefault "root";
        RejectUnauthorized = mkDefault true;
      };
      IpAddressAllow = mkIf (cfg.firewall.allowedIPs != []) (concatStringsSep " " cfg.firewall.allowedIPs);
    };

    # Security hardening
    systemd.services.cockpit = {
      serviceConfig = {
        ProtectHome = "read-only";
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };
  };
}
