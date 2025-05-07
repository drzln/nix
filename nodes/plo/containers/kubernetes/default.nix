# nodes/plo/containers/kubernetes/default.nix
{
  pkgs,
  requirements,
  ...
}: let
  state.version = "24.11";
  user = {
    name = "luis";
    uid = 1001;
    gid = 1001;
    shell = pkgs.zsh;
    pubkey = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo
    '';
  };
  host = {
    bridge = "internal-br-1";
    gateway = "10.3.0.1";
    prefix = 24;
  };
  domainConfig = {
    name = "kubernetes";
    domain_prefix = "local.nexus.io";
  };
  domain = "${domainConfig.name}.${domainConfig.domain_prefix}";
  ip.space = {
    bastion = {
      prefix = host.prefix;
      local = "10.3.0.2";
    };
  };
  dns.addresses = [
    "/bastion.${domain}/${ip.space.bastion.local}"
  ];
  nixos-common-module = {pkgs, ...}: {
    imports = [
      requirements.inputs.home-manager.nixosModules.home-manager
      requirements.inputs.nix-kubernetes.nixosModules.kubernetes
    ];
    system.stateVersion = state.version;
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
      settings.server = [
        "${host.gateway}"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
    networking = {
      firewall.enable = false;
      domain = domain;
      useDHCP = false;
      defaultGateway = host.gateway;
    };
    programs.zsh.enable = true;
    users = {
      users = {
        ${user.name} = {
          isSystemUser = false;
          isNormalUser = true;
          uid = user.uid;
          group = user.name;
          shell = user.shell;
          createHome = true;
          openssh.authorizedKeys.keys = [user.pubkey];
        };
        root.openssh.authorizedKeys.keys = [];
      };
      groups.${user.name}.gid = user.gid;
    };
    security.sudo.extraConfig = "${user.name} ALL=(ALL) NOPASSWD:ALL";
    environment.systemPackages = with pkgs; [dig nmap];
  };

  home-manager-common-module = {
    imports = [requirements.inputs.self.homeManagerModules.blackmatter];
    home = {
      stateVersion = state.version;
      homeDirectory = "/home/${user.name}";
      packages = with pkgs; [vim git];
      sessionVariables = {EDITOR = "vim";};
    };
    programs.ssh = {
      enable = true;
      userKnownHostsFile = "/dev/null";
      extraConfig = "StrictHostKeyChecking no";
    };
    blackmatter = {
      enable = true;
      components = {
        nvim = {
          enable = true;
          package = pkgs.neovim;
        };
        shell.enable = true;
        desktop.enable = false;
        gitconfig = {
          enable = true;
          email = "drzzln@protonmail.com";
          user = user.name;
        };
      };
    };
  };

  container.defaults = {
    hostBridge = host.bridge;
    privateNetwork = true;
    autoStart = true;
    ephemeral = true;
  };

  mk-nixos-container-module = {baseConfig}: {...}: {
    imports = [nixos-common-module baseConfig];
  };

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
            home-manager.users.${user.name}.imports = [home-manager-common-module];
          };
        };
      }
      // container.defaults;
  };
in {
  # inherit containers;

  networking = {
    nat = {
      enable = true;
      internalInterfaces = [host.bridge];
    };
    networking.bridges."${host.bridge}" = {
      interfaces = [];
      ipv4.addresses = [
        {
          address = host.gateway;
          prefixLength = host.prefix;
        }
      ];
      ipv6.addresses = [];
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      listen-address = "127.0.0.1,${host.gateway}";
      address = dns.addresses;
    };
  };
}
