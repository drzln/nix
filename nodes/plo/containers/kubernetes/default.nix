{
  pkgs,
  requirements,
  ...
}: let
  state.version = "24.11";

  pubkey = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo
  '';

  # This sets up the host, plus defines container IPs, etc.
  host = {
    bridge = "internal-br-1";
    gateway = "10.3.0.1";
    prefix = 24;
  };

  name = "kubernetes";
  domain_prefix = "local.pleme.io";
  domain = "${name}.${domain_prefix}";

  # IP addresses for each container
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

  # DNS mappings
  dns.addresses = [
    "/bastion.${domain}/${ip.space.bastion.local}"
    "/k8s-master.${domain}/${ip.space.k8s-master.local}"
    "/k8s-worker.${domain}/${ip.space.k8s-worker.local}"
  ];

  # Common config for containers
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

    # Basic SSH setup
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

    # Basic user + packages
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

  # Default container settings
  container.defaults = {
    hostBridge = host.bridge;
    privateNetwork = true;
    autoStart = true;
    ephemeral = true; # ephemeral so container state is dropped if container is destroyed
  };

  # Helper function for container modules
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

  # Home Manager config for user 'luis'
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

            # optional home manager
            home-manager.users.luis = {
              imports = [home-manager-common-module];
            };
          };
        };
      }
      // container.defaults;

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

            # Master node => runs etcd, pinned to an older version
            # (set below in the overlay)
            # services.etcd.package = pkgs.etcd-special;

            services.kubernetes = {
              roles = ["master"];
              masterAddress = ip.space.k8s-master.local;
            };
            virtualisation.docker.enable = true;
          };
        };
      }
      // container.defaults;

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

  ###########################################################################
  # Overlay: Pin/downgrade etcd to a known older version (no Go override)
  ###########################################################################
  nixpkgs.overlays = [
    # (self: super: {
    #   etcd-special = super.etcd.overrideAttrs (old: {
    #     version = "3.4.24"; # Example stable older version
    #     src = self.fetchFromGitHub {
    #       owner = "etcd-io";
    #       repo = "etcd";
    #       rev = "v3.4.24";
    #       sha256 = "sha256-jbMwSvCn9y4md60pWd7nF2Ck2XJDkYfg5olr1qVrPd4="; # use nix-prefetch-url or similar
    #     };
    #     patches = [];
    #     # If tests still fail, you can skip them:
    #     # doCheck = false;
    #   });
    # })
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
