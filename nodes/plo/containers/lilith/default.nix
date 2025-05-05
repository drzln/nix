# nodes/plo/containers/lilith/default.nix
{
  pkgs,
  requirements,
  ...
}: let
  data = import ../goomba-data.nix {};
  name = "lilith";
  bridge = "internal-br-2";
  gateway = "10.2.0.1";
  prefix = 24;
  domain = "${name}.${data.domain_prefix}";
  user.name = data.user;
  user.uid = data.uid;
  user.ssh.pubkey = data.ssh-pub-key;
  state.version = "24.11";

  ip.space = {
    main = {
      prefix = prefix;
      local = "10.2.0.2";
    };

    minio = {
      prefix = 24;
      local = "10.2.0.3";
    };

    haproxy = {
      local = "10.2.0.4";
      prefix = 24;
    };
    # dnsmasq = {
    #   prefix = 24;
    #   local = "10.1.0.3";
    # };
  };

  dns.addresses = [
    "/main.${domain}/${ip.space.main.local}"
    "/minio.${domain}/${ip.space.minio.local}"
    "/haproxy.${domain}/${ip.space.haproxy.local}"
    # "/dnsmasq.${domain}/${ip-space.dnsmasq.local}"
  ];

  nixos-common-module = {
    lib,
    config,
    pkgs,
    ...
  }: {
    imports = [
      requirements.inputs.home-manager.nixosModules.home-manager
    ];
    system.stateVersion = state.version;
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
    services.dnsmasq.settings.server = [
      gateway
      "8.8.8.8"
      "8.8.4.4"
    ];

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
      openssh.authorizedKeys.keys = [user.ssh.pubkey];
    };
    users.groups."${user.name}".gid = user.uid;
    security.sudo.extraConfig = ''${user.name} ALL=(ALL) NOPASSWD:ALL'';
    users.users.root.openssh.authorizedKeys.keys = [];
    environment.systemPackages = with pkgs; [dig nmap];
  };

  container.defaults = {
    hostBridge = bridge;
    privateNetwork = true;
    autoStart = true;
    ephemeral = true;
    bindMounts = {
      "/home/${user.name}" = {
        hostPath = "/home/${user.name}/.goomba/${name}/mnt/home/${user.name}";
        isReadOnly = false;
      };
    };
  };

  mk-nixos-container-module = {main}: let
    container-module = {
      lib,
      config,
      pkgs,
      ...
    }: {
      imports = [
        # ../../../../modules/nixos/blackmatter/components/microservices/${name}
        nixos-common-module
        main
      ];
    };
  in
    container-module;

  home-manager-common-module = {
    imports = [
      requirements.outputs.homeManagerModules.blackmatter
    ];
    home.stateVersion = state.version;
    home.packages = with pkgs; [vim git];
    home.homeDirectory = "/home/${user.name}";
    home.sessionVariables = {EDITOR = "vim";};
    programs.ssh.enable = true;
    programs.ssh.userKnownHostsFile = "/dev/null";
    programs.ssh.extraConfig = ''
      StrictHostKeyChecking no
    '';
    blackmatter.enable = true;
    blackmatter.components.nvim.enable = true;
    blackmatter.components.nvim.package = pkgs.neovim;
    blackmatter.components.shell.enable = true;
    blackmatter.components.desktop.enable = false;
    blackmatter.components.gitconfig.enable = true;
    blackmatter.components.gitconfig.email = "luis@pleme.io";
    blackmatter.components.gitconfig.user = "luis";
  };

  containers = {
    haproxy =
      {
        config = mk-nixos-container-module {
          main = {
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.haproxy.local;
                prefixLength = ip.space.haproxy.prefix;
              }
            ];
            networking.hostName = "haproxy";
            services.haproxy = {
              enable = true;
              config = ''
                global
                  # log stdout format raw local0
                  maxconn 2000

                defaults
                  mode http
                  log global
                  option httplog
                  option forwardfor
                  timeout connect 5000ms
                  timeout client 50000ms
                  timeout server 50000ms

                frontend http-in
                  bind *:80
                	# store the original header
                	http-request set-var(txn.original_host) req.hdr(Host)

                  # Define an ACL that matches requests whose URL path begins with /minio
                  acl is_minio_console path_beg /minio
                  # acl is_minio_api path_beg /minio/api

                  use_backend minio_backend_console if is_minio_console
                  # use_backend minio_backend_api if is_minio_api

                  # Fallback default backend for other traffic
                  # default_backend servers

                backend minio_backend_console
                	server minio minio.${domain}:9001 check
                	http-request set-path %[path,regsub(^/minio/,/)]
                	http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
                	http-request set-header Host minio.${domain}
                	http-request set-header X-Forwarded-Port %[dst_port]
                	http-response replace-header Location ^(https?://)minio\.${domain}:9001(.*) /\1%[var(txn.host)]/minio\2
                	http-response replace-header Location ^/(.*) /minio/\1

                # backend minio_backend_api
                # 	server minio minio.lilith.local.pleme.io:9000
                # 	# Rewrite Location headers so that if Minio sends a redirect to :9001,
                # 	# it is replaced with the external hostname (and port 80 by omission)
                # 	# http-response replace-header Location ^(https?://)[^:/]+(:9001)(.*)$ \1haproxy.${domain}\3
              '';
            };
          };
        };
      }
      // container.defaults;

    minio =
      {
        bindMounts = {
          "/var/lib/minio" = {
            hostPath = "/home/${user.name}/.goomba/${name}/mnt/var/lib/minio";
            isReadOnly = false; # set to true if you want a read-only mount
          };
        };
        config = mk-nixos-container-module {
          main = {
            imports = [
              ../../../../modules/nixos/blackmatter/components/microservices/minio
            ];
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.minio.local;
                prefixLength = ip.space.minio.prefix;
              }
            ];
            networking.hostName = "minio";
            blackmatter.components.microservices.minio.enable = true;
          };
        };
      }
      // container.defaults;

    "${name}" =
      ############################################################################
      # default container
      ############################################################################
      {
        config = mk-nixos-container-module {
          main = {
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.main.local;
                prefixLength = ip.space.main.prefix;
              }
            ];
            networking.hostName = "${name}";
            home-manager.users.${user.name} = {
              imports = [home-manager-common-module];
            };
          };
        };
      }
      // container.defaults;
  };
in {
  inherit containers;
  # host level node settings to run containers the goomba way
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [bridge];
  networking.bridges.${bridge}.interfaces = []; # Explicitly empty
  networking.interfaces.${bridge} = {
    ipv4 = {
      addresses = [
        {
          address = gateway;
          prefixLength = prefix;
        }
      ];
      # Don't create a default route for the bridge
      routes = [];
    };
    # Keep IPv6 disabled for internal network
    ipv6.addresses = [];
  };
  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    listen-address = "127.0.0.1,${gateway}";
  };
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.settings.address = dns.addresses;
}
