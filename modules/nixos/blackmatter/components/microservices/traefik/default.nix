{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
################################################################################
# NixOS Module for Traefik with SSL for *.local
################################################################################
  let
    t = config.blackmatter.components.microservices.traefik;

    # Default Traefik settings
    defaultSettings = {
      api = {
        insecure = true;
      };
      entryPoints = {
        traefik = {
          address = ":8081";
        };
        web = {
          address = ":8080";
        };
        websecure = {
          address = ":8443";
          tls = true;
        };
      };
      log = {
        level = "INFO";
      };
    };

    # Merge default settings with user-provided settings
    finalSettings =
      if t.settings == {}
      then defaultSettings
      else t.settings;

    # Derivation to generate SSL certificates
    certs =
      pkgs.runCommand "generate-local-cert"
      {
        buildInputs = [pkgs.openssl];
      } ''
        mkdir -p $out/certs

        # Generate CA key and certificate
        openssl genrsa -out $out/certs/ca.key 2048
        openssl req -x509 -new -nodes -key $out/certs/ca.key -sha256 -days 3650 -out $out/certs/ca.crt \
          -subj "/C=US/ST=Test/L=Local/O=Traefik/OU=DevOps/CN=*.local"

        # Generate server key
        openssl genrsa -out $out/certs/server.key 2048

        # Generate server CSR
        openssl req -new -key $out/certs/server.key -out $out/certs/server.csr \
          -subj "/C=US/ST=Test/L=Local/O=Traefik/OU=DevOps/CN=*.local"

        # Sign server certificate with the CA
        openssl x509 -req -in $out/certs/server.csr -CA $out/certs/ca.crt -CAkey $out/certs/ca.key \
          -CAcreateserial -out $out/certs/server.crt -days 3650 -sha256

        echo "SSL certificate for *.local generated in $out/certs"
      '';
  in {
    options = {
      blackmatter.components.microservices.traefik = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable the Traefik service.";
        };

        namespace = mkOption {
          type = types.str;
          default = "default";
          description = "Namespace for the Traefik systemd service name.";
        };

        settings = mkOption {
          type = types.attrsOf types.anything;
          default = {};
          description = "Traefik dynamic settings (overrides defaults if non-empty).";
        };

        command = mkOption {
          type = types.str;
          default = "${pkgs.traefik}/bin/traefik --configFile=/etc/traefik/traefik.yml";
          description = ''
            Command to start Traefik. By default points to the package's binary
            and uses /etc/traefik/traefik.yml.
          '';
        };

        package = mkOption {
          type = types.package;
          default = pkgs.traefik;
          description = "Which Traefik derivation to use.";
        };
      };
    };

    config = mkIf t.enable {
      # Write Traefik configuration to /etc/traefik/traefik.yml
      environment.etc."traefik/traefik.yml".text = builtins.toJSON (finalSettings // {});
      environment.etc."traefik/certs/ca.crt".source = "${certs}/certs/ca.crt";
      environment.etc."traefik/certs/server.crt".source = "${certs}/certs/server.crt";
      environment.etc."traefik/certs/server.key".source = "${certs}/certs/server.key";

      # Systemd service for Traefik
      systemd.services."${t.namespace}-traefik" = {
        description = "${t.namespace} Traefik Service";
        wantedBy = ["multi-user.target"];
        serviceConfig.ExecStart = t.command;
      };

      # Dnsmasq configuration for local domain resolution
      services.dnsmasq.settings = {
        address = ["/${t.namespace}-traefik.local/127.0.0.1"];
      };
    };
  }
