{
  pkgs,
  requirements,
  ...
}: let
  state.version = "24.11";

  pubkey = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo
  '';

  # This configuration configures the host then configures any downstream containers.
  host = {
    bridge = "internal-br-1";
    gateway = "10.3.0.1";
    prefix = 24;
  };

  name = "kubernetes";
  domain_prefix = "local.pleme.io";
  domain = "${name}.${domain_prefix}";

  # IP addresses for each container or service on our internal bridge
  ip.space = {
    bastion = {
      prefix = host.prefix;
      local = "10.3.0.2";
    };

    # Add the master and worker addresses
    k8s-master = {
      prefix = host.prefix;
      local = "10.3.0.3";
    };
    k8s-worker = {
      prefix = host.prefix;
      local = "10.3.0.4";
    };
  };

  # DNS mappings so we can SSH or resolve by container name within this domain
  dns.addresses = [
    "/bastion.${domain}/${ip.space.bastion.local}"
    "/k8s-master.${domain}/${ip.space.k8s-master.local}"
    "/k8s-worker.${domain}/${ip.space.k8s-worker.local}"
  ];

  # Common module imported by each container
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

    # Basic SSH config (no root login, no password login)
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "no";
    services.openssh.settings.PasswordAuthentication = false;

    # DNS and networking basics
    services.dnsmasq.enable = false;
    services.dnsmasq.resolveLocalQueries = true;
    services.dnsmasq.settings.server = [
      "${host.gateway}"
      "8.8.8.8"
      "8.8.4.4"
    ];
    networking.firewall.enable = false;
    networking.domain = domain;
    networking.useDHCP = false;
    networking.defaultGateway = host.gateway;

    # Basic packages, user config
    programs.zsh.enable = true;
    users.users.luis = {
      isSystemUser = false;
      isNormalUser = true;
      uid = 1001;
      group = "luis";
      shell = pkgs.zsh;
      createHome = true;
      openssh.authorizedKeys.keys = [pubkey];
    };
    users.groups.luis.gid = 1001;
    security.sudo.extraConfig = ''luis ALL=(ALL) NOPASSWD:ALL'';
    environment.systemPackages = with pkgs; [dig nmap];
    users.users.root.openssh.authorizedKeys.keys = [];
  };

  # Default options for all containers
  container.defaults = {
    hostBridge = host.bridge;
    privateNetwork = true;
    autoStart = true;
    ephemeral = true; # ephemeral so container state is dropped if container is destroyed
  };

  # Helper function to build container modules from partial configs
  mk-nixos-container-module = {baseConfig}: {
    lib,
    config,
    pkgs,
    ...
  }: {
    imports = [
      nixos-common-module
      baseConfig
    ];
  };

  # A common Home Manager config for user 'luis' in containers that want it
  home-manager-common-module = {
    imports = [
      requirements.inputs.self.homeManagerModules.blackmatter
    ];
    home.stateVersion = state.version;
    home.packages = with pkgs; [vim git];
    home.homeDirectory = "/home/luis";
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

  # Our containers definition
  containers = {
    # The existing bastion container for SSH / management
    bastion =
      {
        config = mk-nixos-container-module {
          baseConfig = {
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.bastion.local;
                prefixLength = ip.space.bastion.prefix;
              }
            ];
            networking.hostName = "bastion";
            # Enable home-manager for user 'luis'
            home-manager.users.luis = {
              imports = [home-manager-common-module];
            };
          };
        };
      }
      // container.defaults;

    # New: Kubernetes master node
    k8s-master =
      {
        config = mk-nixos-container-module {
          baseConfig = {
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.k8s-master.local;
                prefixLength = ip.space.k8s-master.prefix;
              }
            ];
            networking.hostName = "k8s-master";

            # Upstream Kubernetes Master role
            services.kubernetes = {
              roles = ["master"];
              masterAddress = ip.space.k8s-master.local;
              # By default, this sets up etcd, kube-apiserver, controller-manager, scheduler,
              # flannel, and kube-proxy on this container.
            };

            # If you want to run pods on the master as well,
            # you can add "node" to roles or remove the master taint manually.
            # e.g. roles = [ "master" "node" ];

            # Provide a container runtime if you plan to schedule pods here:
            virtualisation.docker.enable = true;
          };
        };
      }
      // container.defaults;

    # New: Kubernetes worker node
    k8s-worker =
      {
        config = mk-nixos-container-module {
          baseConfig = {
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.k8s-worker.local;
                prefixLength = ip.space.k8s-worker.prefix;
              }
            ];
            networking.hostName = "k8s-worker";

            # Upstream Kubernetes Node role
            services.kubernetes = {
              roles = ["node"];
              masterAddress = ip.space.k8s-master.local;
              # This runs kubelet, kube-proxy, and flannel, connecting to the master.
            };

            # Provide container runtime for pods:
            virtualisation.docker.enable = true;
          };
        };
      }
      // container.defaults;
  };
in {
  inherit containers;
  nixpkgs.overlays = [
    (self: super: {
      etcd = super.etcd.override {
        doCheck = false; # or your patch/override
      };
    })
  ];

  # Host-level node settings
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [host.bridge];

  networking.bridges."${host.bridge}".interfaces = []; # Explicitly empty
  networking.interfaces."${host.bridge}" = {
    ipv4 = {
      addresses = [
        {
          address = host.gateway;
          prefixLength = host.prefix;
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
    listen-address = "127.0.0.1,${host.gateway}";
  };
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.settings.address = dns.addresses;
}
