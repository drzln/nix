{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.microservices.isolationist;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NAT-based NixOS container for a microservice.";
    };

    containerName = mkOption {
      type = types.str;
      default = "example-nat-container";
      description = "Name of the container (systemd-nspawn) instance.";
    };

    containerHostIP = mkOption {
      type = types.str;
      default = "10.42.0.1";
      description = ''
        IP address on the host side of the veth pair. Must be in the same subnet
        as the containerLocalIP.
      '';
    };

    containerLocalIP = mkOption {
      type = types.str;
      default = "10.42.0.2";
      description = ''
        IP address on the container side of the veth pair.
      '';
    };

    externalInterface = mkOption {
      type = types.str;
      default = "enp3s0";
      description = ''
        The host's primary interface used for NAT egress (LAN or internet).
        Replace with your actual interface name, e.g. "eth0".
      '';
    };

    # Example: if you want to run a particular service (e.g. an internal Nginx or something)
    # inside the container, you can add toggles or settings here.
    exampleService = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable an example service (like Nginx) inside the container.";
      };
    };
  };
in {
  options = {
    blackmatter.components.microservices.isolationist = interface;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      ### 1) Container definition ###
      containers = {
        "${cfg.containerName}" = {
          autoStart = true;
          privateNetwork = true;

          # The host side of the veth pair
          hostAddress = cfg.containerHostIP;
          # The container side of the veth pair
          localAddress = cfg.containerLocalIP;

          # "config" is the container's own NixOS configuration.
          config = mkMerge [
            # Let’s open typical HTTP ports, or whichever your service needs
            {
              networking.firewall.allowedTCPPorts = [80 443];
              # Default route & DNS so the container can reach the internet via NAT
              networking.defaultGateway = cfg.containerHostIP;
              networking.nameservers = ["1.1.1.1"];
            }

            # If we want to enable a small example service in the container:
            (mkIf cfg.exampleService.enable {
              services.nginx.enable = false;
              # For example, set up a simple Nginx site
              services.nginx.virtualHosts."example.local" = {
                listen = [
                  {
                    addr = "0.0.0.0";
                    port = 80;
                  }
                ];
                root = "/var/www";
              };
            })
          ];
        };
      };

      ### 2) NAT / Masquerading on the host ###
      # This uses the built-in NixOS NAT options
      # so the container can get outbound access to LAN/Internet.
      networking.nat.enable = true;

      # Outbound interface (the real network interface):
      networking.nat.externalInterface = cfg.externalInterface;

      # The host side of the container's veth is typically named "ve-<containerName>"
      # or "ve-containers-<containerName>", but the exact name can vary.
      # You can confirm with `ip link` or `networkctl` after the container starts.
      networking.nat.internalInterfaces = [
        # A guess at what systemd-nspawn calls it
        "ve-${cfg.containerName}"
      ];
    })
  ];
}
