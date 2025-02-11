{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.jitsi;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Jitsi video conferencing suite";
    };

    namespace = mkOption {
      type = types.str;
      default = "video-conf";
      description = mdDoc ''
        Logical namespace for Jitsi services
      '';
    };

    hostname = mkOption {
      type = types.str;
      example = "meet.example.com";
      description = mdDoc "Primary domain for Jitsi Meet";
    };

    meet = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable Jitsi Meet web interface";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.jitsi-meet;
        description = mdDoc "Jitsi Meet package";
      };

      config = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = mdDoc ''
          Jitsi Meet configuration overrides
          See: https://github.com/jitsi/jitsi-meet/blob/master/config.js
        '';
      };

      interfaceConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = mdDoc ''
          Jitsi Meet interface configuration overrides
          See: https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js
        '';
      };
    };

    videobridge = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable Jitsi Videobridge";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.jitsi-videobridge;
        description = mdDoc "Videobridge package";
      };

      port = mkOption {
        type = types.port;
        default = 5347;
        description = mdDoc "Colibri web socket port";
      };

      apis = {
        rest = mkOption {
          type = types.bool;
          default = true;
          description = mdDoc "Enable REST API";
        };

        xmpp = mkOption {
          type = types.bool;
          default = true;
          description = mdDoc "Enable XMPP API";
        };
      };
    };

    jicofo = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable Jicofo conference focus";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.jicofo;
        description = mdDoc "Jicofo package";
      };
    };

    xmpp = {
      package = mkOption {
        type = types.package;
        default = pkgs.prosody;
        description = mdDoc "XMPP server package";
      };

      domain = mkOption {
        type = types.str;
        default = "auth.${cfg.hostname}";
        description = mdDoc "XMPP server domain";
      };

      secretFile = mkOption {
        type = types.str;
        default = "/var/lib/jitsi/auth-secret";
        description = mdDoc "Path to shared secret file";
      };
    };

    database = {
      type = mkOption {
        type = types.enum [ "postgresql" "h2" ];
        default = "postgresql";
        description = mdDoc "Database type for persistent storage";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = mdDoc "Database host";
      };

      name = mkOption {
        type = types.str;
        default = "jitsi";
        description = mdDoc "Database name";
      };

      user = mkOption {
        type = types.str;
        default = "jitsi";
        description = mdDoc "Database user";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/jitsi/db-pass";
        description = mdDoc "Path to database password file";
      };
    };

    ssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable SSL/TLS encryption";
      };

      certificate = mkOption {
        type = types.path;
        default = "/var/lib/jitsi/ssl/fullchain.pem";
        description = mdDoc "SSL certificate path";
      };

      certificateKey = mkOption {
        type = types.path;
        default = "/var/lib/jitsi/ssl/privkey.pem";
        description = mdDoc "SSL private key path";
      };
    };

    firewall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Open necessary ports in firewall";
      };

      rtp = {
        portRange = mkOption {
          type = types.str;
          default = "10000-20000";
          description = mdDoc "UDP port range for RTP media";
        };
      };
    };

    authentication = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable user authentication";
      };

      type = mkOption {
        type = types.enum [ "internal" "ldap" "jwt" ];
        default = "internal";
        description = mdDoc "Authentication method";
      };
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          jitsi = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Core services
    services.jitsi-meet = mkIf cfg.meet.enable {
      enable = true;
      inherit (cfg) hostname;
      config = cfg.meet.config;
      interfaceConfig = cfg.meet.interfaceConfig;
    };

    services.jitsi-videobridge = mkIf cfg.videobridge.enable {
      enable = true;
      inherit (cfg) hostname;
      openTCPPorts = [ cfg.videobridge.port ];
      apis = mkMerge [
        (mkIf cfg.videobridge.apis.rest [ "rest" ])
        (mkIf cfg.videobridge.apis.xmpp [ "xmpp" ])
      ];
    };

    services.jicofo = mkIf cfg.jicofo.enable {
      enable = true;
      xmppHost = cfg.xmpp.domain;
    };

    # XMPP configuration
    services.prosody = {
      enable = true;
      extraModules = [
        "bosh"
        "websocket"
        "smacks"
        "pubsub"
        "mam"
      ];
      extraConfig = ''
        VirtualHost "${cfg.xmpp.domain}"
          authentication = "internal_plain"
          ssl = {
            certificate = "${cfg.ssl.certificate}";
            key = "${cfg.ssl.certificateKey}";
          }
          modules_enabled = {
            "ping";
            "speakerstats";
            "conference_duration";
          }
      '';
    };

    # Database configuration
    services.postgresql = mkIf (cfg.database.type == "postgresql") {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensurePermissions."DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      }];
    };

    # Networking
    networking.firewall = mkIf cfg.firewall.enable {
      allowedTCPPorts = [
        80
        443 # Web
        5222 # XMPP
        cfg.videobridge.port
      ];
      allowedUDPPortRanges = [
        {
          from = elemAt (splitString "-" cfg.firewall.rtp.portRange) 0;
          to = elemAt (splitString "-" cfg.firewall.rtp.portRange) 1;
        }
      ];
    };

    # SSL configuration
    security.acme.certs.${cfg.hostname} = mkIf cfg.ssl.enable {
      inherit (cfg.ssl) certificate certificateKey;
      reloadServices = [ "nginx" "prosody" ];
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostname} = {
        forceSSL = cfg.ssl.enable;
        sslCertificate = cfg.ssl.certificate;
        sslCertificateKey = cfg.ssl.certificateKey;
        locations."/" = {
          root = "${cfg.meet.package}/share/jitsi-meet";
        };
        locations."/xmpp-websocket" = {
          proxyPass = "http://localhost:5280/xmpp-websocket";
          proxyWebsockets = true;
        };
      };
    };

    # Secret management
    systemd.services.jitsi-secrets = {
      wantedBy = [ "multi-user.target" ];
      before = [ "jitsi-videobridge.service" "jicofo.service" ];
      script = ''
        mkdir -p /var/lib/jitsi
        [ -f ${cfg.xmpp.secretFile} ] || openssl rand -hex 16 > ${cfg.xmpp.secretFile}
        [ -f ${cfg.database.passwordFile} ] || openssl rand -hex 16 > ${cfg.database.passwordFile}
      '';
      serviceConfig.Type = "oneshot";
    };

    # Authentication integration
    services.jitsi-meet.config = mkIf cfg.authentication.enable {
      enableUserRolesBasedOnToken = true;
      disableLocalVideoFlip = true;
      requireDisplayName = true;
      enableEmailInStats = false;
    };
  };
}
