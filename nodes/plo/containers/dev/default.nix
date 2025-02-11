{ config, pkgs, requirements, ... }:
let
  name = "dev";
  gateway = "10.1.0.1";
  prefix = 24;
  domain = "${name}.local.pleme.io";
  user.name = "luis";
  user.uid = 1001;
  data = import ../goomba-data.nix { };
  user.ssh.pubkey = data.ssh-pub-key;

  ip.space = {
    main = {
      prefix = prefix;
      local = "10.1.0.2";
    };
    # haproxy = {
    #   local = "10.1.0.2";
    #   prefix = 24;
    # };
    # minio = {
    #   prefix = 24;
    #   local = "10.1.0.3";
    # };
    # dnsmasq = {
    #   prefix = 24;
    #   local = "10.1.0.3";
    # };
  };

  dns.addresses = [
    "/main.${domain}/${ip.space.main.local}"
    # "/haproxy.${domain}/${ip.space.haproxy.local}"
    # "/minio.${domain}/${ip.space.minio.local}"
    # "/dnsmasq.${domain}/${ip-space.dnsmasq.local}"
  ];

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
		programs.zsh.enable = true;
    users.users."${user.name}" = {
      isSystemUser = false;
      isNormalUser = true;
      uid = user.uid;
      group = user.name;
      shell = pkgs.zsh;
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
      hostBridge = "internal-br-1";
      privateNetwork = true;
      autoStart = true;
      ephemeral = true;
    };

  mk-container-module = { main }:
    let
      container-module = { lib, config, pkgs, ... }: {
        imports = [
          # ../../../../modules/nixos/blackmatter/components/microservices/minio
          # ../../../../modules/nixos/blackmatter/components/microservices/${name}
          common
          main
        ];
      };
    in
    container-module;

  containers =
    {
      # haproxy =
      #   {
      #     config = mk-container-module {
      #       main = {
      #         networking.interfaces.eth0.ipv4.addresses = [{
      #           address = ip.space.haproxy.local;
      #           prefixLength = ip.space.haproxy.prefix;
      #         }];
      #         networking.hostName = "haproxy";
      #         services.haproxy = {
      #           enable = true;
      #           config = ''
      #             global
      #               log stdout format raw local0
      #               maxconn 2000
      #
      #             defaults
      #               mode http
      #               log global
      #               option httplog
      #               option dontlognull
      #               timeout connect 5000ms
      #               timeout client 50000ms
      #               timeout server 50000ms
      #
      #             # frontend http-in
      #             #   bind *:80
      #             #   default_backend servers
      #
      #             # backend servers
      #             #   server server1 127.0.0.1:8000 maxconn 32
      #           '';
      #         };
      #       };
      #     };
      #   } // container.defaults;

      # minio =
      #   {
      #     bindMounts = {
      #       "/var/lib/minio" = {
      #         hostPath = "/home/luis/.goomba/attic/mnt/var/lib/minio";
      #         isReadOnly = false; # set to true if you want a read-only mount
      #       };
      #     };
      #     config = mk-container-module {
      #       main = {
      #         networking.interfaces.eth0.ipv4.addresses = [{
      #           address = ip.space.minio.local;
      #           prefixLength = ip.space.minio.prefix;
      #         }];
      #         networking.hostName = "minio";
      #         blackmatter.components.microservices.minio.enable = true;
      #       };
      #     };
      #   } // container.defaults;

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

  networking.bridges.internal-br-1.interfaces = [ ]; # Explicitly empty
  networking.interfaces.internal-br-1 = {
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
  #     name = "internal-br-1";
  #     address = "10.1.0.1";
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

