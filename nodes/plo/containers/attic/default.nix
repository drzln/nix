{ config, pkgs, requirements, ... }:
let
  name = "attic";
  gateway = "10.0.0.1";
  domain = "${name}.local.pleme.io";
	prefix = 24;

  ip.space = {
    haproxy = {
      local = "10.0.0.2";
      prefix = prefix;
    };
    minio = {
      prefix = prefix;
      local = "10.0.0.3";
    };
    main = {
      prefix = prefix;
      local = "10.0.0.4";
    };
    # dnsmasq = {
    #   prefix = 24;
    #   local = "10.1.0.3";
    # };
  };


  dns.addresses = [
    "/haproxy.${domain}/${ip.space.haproxy.local}"
    "/minio.${domain}/${ip.space.minio.local}"
    "/main.${domain}/${ip.space.main.local}"
    # "/dnsmasq.${domain}/${ip-space.dnsmasq.local}"
  ];

  user.name = "luis";
  user.uid = 1001;
  data = import ../goomba-data.nix { };
  user.ssh.pubkey = data.ssh-pub-key;

  host = { };
  common = { lib, config, pkgs, ... }: {
    system.stateVersion = "24.11";
    # permit user level ssh but no root
    # user will be a privileged managed user
    # typically your local user if this is a local
    # dev environment and an "automation" user in other
    # places.
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "no";
    services.openssh.settings.PasswordAuthentication = false;
    # add service dns addesses to each node to speak to each other
    # supports ssh ${component}.${domain}
    services.dnsmasq.enable = true;
    services.dnsmasq.resolveLocalQueries = true;
    services.dnsmasq.settings.address = dns.addresses;

    networking.firewall.enable = false;
    networking.domain = domain;
    networking.useDHCP = false;
    networking.defaultGateway = gateway;
    users.users."${user.name}" = {
      isSystemUser = false;
      isNormalUser = true;
      uid = user.uid;
      group = user.name;
      shell = pkgs.bash;
      createHome = true;
      openssh.authorizedKeys.keys = [ user.ssh.pubkey ];
    };
    users.groups."${user.name}".gid = user.uid;
    security.sudo.extraConfig = ''${user.name} ALL=(ALL) NOPASSWD:ALL'';
    users.users.root.openssh.authorizedKeys.keys = [ ];
    environment.systemPackages = with pkgs; [ dig nmap ];
  };

  container.defaults =
    {
      hostBridge = "internal-br-0";
      privateNetwork = true;
      autoStart = true;
      ephemeral = true;
    };

  mk-container-module = { main }:
    let
      container-module = { lib, config, pkgs, ... }: {
        imports = [
          ../../../../modules/nixos/blackmatter/components/microservices/minio
          # ../../../../modules/nixos/blackmatter/components/microservices/${name}
          common
          main
        ];
      };
    in
    container-module;

  containers =
    {
      haproxy =
        {
          config = mk-container-module {
            main = {
              networking.interfaces.eth0.ipv4.addresses = [{
                address = ip.space.haproxy.local;
                prefixLength = ip.space.haproxy.prefix;
              }];
              networking.hostName = "haproxy";
              services.haproxy = {
                enable = true;
                config = ''
                  global
                    log stdout format raw local0
                    maxconn 2000

                  defaults
                    mode http
                    log global
                    option httplog
                    option dontlognull
                    timeout connect 5000ms
                    timeout client 50000ms
                    timeout server 50000ms

                  # frontend http-in
                  #   bind *:80
                  #   default_backend servers

                  # backend servers
                  #   server server1 127.0.0.1:8000 maxconn 32
                '';
              };
            };
          };
        } // container.defaults;

      minio =
        {
          bindMounts = {
            "/var/lib/minio" = {
              hostPath = "/home/luis/.goomba/attic/mnt/var/lib/minio";
              isReadOnly = false; # set to true if you want a read-only mount
            };
          };
          config = mk-container-module {
            main = {
              networking.interfaces.eth0.ipv4.addresses = [{
                address = ip.space.minio.local;
                prefixLength = ip.space.minio.prefix;
              }];
              networking.hostName = "minio";
              blackmatter.components.microservices.minio.enable = true;
            };
          };
        } // container.defaults;

      "${name}" =
        {
          config = mk-container-module {
            main = {
              networking.interfaces.eth0.ipv4.addresses = [{
                address = ip.space.main.local;
                prefixLength = ip.space.main.prefix;
              }];
              networking.hostName = "${name}";
              # blackmatter.components.microservices.${name}.enable = true;
            };
          };
        } // container.defaults;
    };
in
{
  inherit containers;

  # host level node settings to run containers the goomba way
  imports = [
    requirements.outputs.nixosModules.blackmatter
  ];

  networking.bridges.internal-br-0.interfaces = [ ]; # Explicitly empty
  networking.interfaces.internal-br-0 = {
    ipv4 = {
      addresses = [{
        address = gateway;
        prefixLength = prefix;
      }];
      # Don't create a default route for the bridge
      routes = [ ];
    };
    # Keep IPv6 disabled for internal network
    ipv6.addresses = [ ];
  };
  # blackmatter.components.goomba-global.enable = true;
  # blackmatter.components.goomba-global.bridge =
  #   {
  #     name = "internal-br-0";
  #     address = "10.0.0.1";
  #     prefix = 24;
  #   };
  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.settings.address = dns.addresses;

  # sops.defaultSopsFile = ../../../../secrets.yaml;
  # sops.secrets."attic/key" = {
  #   sopsFile = ../../../../secrets.yaml;
  #   path = "/etc/attic/key";
  # };
}

