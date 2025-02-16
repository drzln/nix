{requirements, ...}: let
  namespace = "plo";
in {
  imports = [
    requirements.inputs.self.nixosModules.blackmatter
  ];

  blackmatter.components.microservices.application_reverse_proxy = {
    inherit namespace;
    enable = false;

    traefik.settings = {
      # old TLS configs when we thought we could reverse proxy mysql
      # tls = {
      #   certificates = [
      #     {
      #       certFile = "/etc/traefik/certs/server.crt";
      #       keyFile = "/etc/traefik/certs/server.key";
      #       stores = [ "default" ];
      #     }
      #   ];
      #   stores = {
      #     default = {
      #       defaultCertificate = {
      #         certFile = "/etc/traefik/certs/server.crt";
      #         keyFile = "/etc/traefik/certs/server.key";
      #       };
      #     };
      #   };
      #   options = {
      #     default = {
      #       sniStrict = true;
      #       minVersion = "VersionTLS12";
      #     };
      #   };
      # };

      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
        # mysql = {
        #   address = ":3306";
        # };
      };

      providers = {
        consulCatalog = {
          endpoint = {
            address = "127.0.0.1:8500";
            scheme = "http";
          };
          exposedByDefault = false;
        };
      };

      log = {
        level = "DEBUG";
        filePath = "/var/log/traefik/traefik.log";
      };

      api = {
        insecure = true;
      };
    };
  };

  services.dnsmasq.settings = {
    address = [
      "/mysql-lilith.local/127.0.0.1"
      "/graphql-lilith.local/127.0.0.1"
      "/opensearch-lilith.local/127.0.0.1"
      "/rabbitmq-lilith.local/127.0.0.1"
    ];
    domainNeeded = false;
  };
}
