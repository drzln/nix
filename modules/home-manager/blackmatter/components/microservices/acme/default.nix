{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.networking.local_dns_tls;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable local DNS server and TLS management.";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = "Namespace for the local DNS and TLS instance.";
    };

    dnsmasq = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable dnsmasq service for local DNS.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.dnsmasq;
        description = "dnsmasq package to use.";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = ''
          # Example: Map *.local.test to 127.0.0.1
          address=/local.test/127.0.0.1
        '';
        description = "Extra configuration for dnsmasq.";
      };
    };

    acme = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ACME service for TLS certificates.";
      };
      email = mkOption {
        type = types.str;
        default = "admin@example.com";
        description = "Email address for ACME registration.";
      };
      domains = mkOption {
        type = types.listOf types.str;
        default = [ "example.local.test" ];
        description = "List of domains to obtain certificates for.";
      };
    };
  };
in
{
  options = {
    blackmatter.components.networking.local_dns_tls = interface;
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.dnsmasq.enable) {
      services.dnsmasq = {
        enable = true;
        package = cfg.dnsmasq.package;
        extraConfig = cfg.dnsmasq.extraConfig;
      };
    })

    (mkIf (cfg.enable && cfg.acme.enable) {
      security.acme = {
        acceptTerms = true;
        defaults.email = cfg.acme.email;
        certs = mapAttrs
          (domain: _: {
            webroot = "/var/www/acme-challenge";
            postRun = ''
              # Reload services that depend on the certificate
              systemctl reload nginx
            '';
          })
          (listToAttrs (map (d: { name = d; value = { }; }) cfg.acme.domains));
      };

      # Ensure the webroot directory exists and is writable
      systemd.tmpfiles.rules = [
        "d /var/www/acme-challenge 0755 nginx nginx"
      ];

      # Example Nginx configuration to serve the ACME challenge
      services.nginx = {
        enable = true;
        virtualHosts = mapAttrs
          (domain: _: {
            serverName = domain;
            root = "/var/www/${domain}";
            locations."/.well-known/acme-challenge" = {
              alias = "/var/www/acme-challenge";
            };
            ssl = true;
            sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
            sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
          })
          (listToAttrs (map (d: { name = d; value = { }; }) cfg.acme.domains));
      };
    })
  ];
}

