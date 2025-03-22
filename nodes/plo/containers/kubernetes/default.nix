{
  pkgs,
  requirements,
  ...
}: let
  state.version = "24.11";

  pubkey = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo
  '';

  # This configuration sets up the host, then configures any containers.
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

  # Common module for each container
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

    # Basic SSH config
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "no";
    services.openssh.settings.PasswordAuthentication = false;

    # DNS + networking
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

    # Basic packages + user config
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
    security.sudo.extraConfig = ''
      luis ALL=(ALL) NOPASSWD:ALL
    '';
    environment.systemPackages = with pkgs; [dig nmap];
    users.users.root.openssh.authorizedKeys.keys = [];
  };

  # Default options for containers
  container.defaults = {
    hostBridge = host.bridge;
    privateNetwork = true;
    autoStart = true;
    ephemeral = true; # ephemeral so container state is dropped if container is destroyed
  };

  # Helper for building container modules
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

  # Home Manager config for user 'luis' in containers
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

  # Our containers
  containers = {
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

            home-manager.users.luis = {
              imports = [home-manager-common-module];
            };
          };
        };
      }
      // container.defaults;

    # Kubernetes master node
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

            # Force the etcd service to use pkgs.etcd,
            # which we've overridden to use go_1_23 in the overlay.
            services.etcd.package = pkgs.etcd;

            # Upstream Kubernetes Master role
            services.kubernetes = {
              roles = ["master"];
              masterAddress = ip.space.k8s-master.local;
            };
            virtualisation.docker.enable = true;
          };
        };
      }
      // container.defaults;

    # Kubernetes worker node
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

            services.kubernetes = {
              roles = ["node"];
              masterAddress = ip.space.k8s-master.local;
            };
            virtualisation.docker.enable = true;
          };
        };
      }
      // container.defaults;
  };
in {
  inherit containers;

  ############################################################################
  # Overlays to downgrade go for etcd
  ############################################################################
  nixpkgs.overlays = [
    (self: super: {
      # If your channel includes pkgs.go_1_23, we can inject it into etcd's build
      etcd = super.etcd.overrideAttrs (old: {
        nativeBuildInputs = let
          oldInputs = old.nativeBuildInputs or [];
          # Filter out the default go if needed:
          filtered = builtins.filter (inp: inp != super.go) oldInputs;
        in
          # Then add go_1_23:
          filtered ++ [super.go_1_23];

        # Optionally also skip tests:
        # doCheck = false;
      });
    })
  ];

  # Host-level networking config
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [host.bridge];

  networking.bridges."${host.bridge}".interfaces = [];
  networking.interfaces."${host.bridge}" = {
    ipv4 = {
      addresses = [
        {
          address = host.gateway;
          prefixLength = host.prefix;
        }
      ];
      routes = [];
    };
    ipv6.addresses = [];
  };

  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    listen-address = "127.0.0.1,${host.gateway}";
  };
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.settings.address = dns.addresses;
}
