# nodes/plo/containers/kubernetes/default.nix
{
  pkgs,
  requirements,
  ...
}: let
  state.version = "24.11";
  base.cidr = "10.3";
  user = {
    name = "luis";
    uid = 1001;
    gid = 1001;
    shell = pkgs.zsh;
    pubkey = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo
    '';
    extraGroups = ["systemd-journal" "wheel" "adm"];
  };
  host = {
    bridge = "internal-br-1";
    gateway = "${base.cidr}.0.1";
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
      local = "${base.cidr}.0.2";
    };
    single = {
      prefix = host.prefix;
      local = "${base.cidr}.0.3";
    };
  };
  dns.addresses = [
    "/bastion.${domain}/${ip.space.bastion.local}"
    "/single.${domain}/${ip.space.single.local}"
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
      settings.server = ["${host.gateway}" "8.8.8.8" "8.8.4.4"];
    };
    networking = {
      firewall.enable = false;
      domain = domain;
      useDHCP = false;
      defaultGateway = host.gateway;
    };
    programs.zsh.enable = true;
    users = {
      users.${user.name} = {
        isNormalUser = true;
        uid = user.uid;
        group = user.name;
        shell = user.shell;
        createHome = true;
        openssh.authorizedKeys.keys = [user.pubkey];
      };
      users.root.openssh.authorizedKeys.keys = [];
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
      packages = with pkgs; [vim git bat];
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
    imports = [
      nixos-common-module
      baseConfig
      requirements.inputs.sops-nix.nixosModules.sops
    ];
  };
in {
  containers = {
    bastion =
      {
        config = mk-nixos-container-module {
          baseConfig = {
            networking.hostName = "bastion";
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.bastion.local;
                prefixLength = ip.space.bastion.prefix;
              }
            ];
            home-manager.users.${user.name}.imports = [home-manager-common-module];
          };
        } {};
      }
      // container.defaults;

    single =
      {
        additionalCapabilities = ["CAP_SYSLOG"];
        extraFlags = [
          "--capability=CAP_SYSLOG"
          "--property=DeviceAllow=char-major-1:rwm" # 1 is “mem”, minor 11 is kmsg
        ];
        bindMounts."/dev/kmsg" = {
          hostPath = "/dev/kmsg";
          isReadOnly = true;
        };
        # bindMounts."/home/luis/.local/share/sheldon/repos" = {
        #   hostPath = "/home/luis/.local/share/sheldon/repos";
        #   isReadOnly = true;
        # };
        # bindMounts."/home/luis/.local/share/sheldon/plugins.zsh" = {
        #   hostPath = "/home/luis/.local/share/sheldon/plugins.zsh";
        #   isReadOnly = true;
        # };
        config = mk-nixos-container-module {
          baseConfig = let
            secretsFile = pkgs.runCommand "secrets.yaml" {} ''
              mkdir -p $out
              cp ${../../../../secrets.yaml} $out/secrets.yaml
            '';
          in {
            networking.hostName = "single";
            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = ip.space.single.local;
                prefixLength = ip.space.single.prefix;
              }
            ];
            home-manager.users.${user.name}.imports = [home-manager-common-module];
            blackmatter.components.kubernetes = {
              enable = true;
              role = "single";
            };
            environment.etc."sops/age/keys.txt".source = /var/lib/sops-nix/key.txt;
            sops.age.keyFile = "/etc/sops/age/keys.txt";
            sops.secrets = {
              "kubernetes/admin/key" = {
                path = "/var/lib/blackmatter/pki/admin.key";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/admin/crt" = {
                path = "/var/lib/blackmatter/pki/admin.crt";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/apiserver/crt" = {
                path = "/var/lib/blackmatter/pki/apiserver.crt";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/apiserver/key" = {
                path = "/var/lib/blackmatter/pki/apiserver.key";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/kubelet/crt" = {
                path = "/var/lib/blackmatter/pki/kubelet.crt";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/san/cnf" = {
                path = "/var/lib/blackmatter/pki/san.cnf";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/ca/crt" = {
                path = "/var/lib/blackmatter/pki/ca.crt";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/ca/key" = {
                path = "/var/lib/blackmatter/pki/ca.key";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/etcd/crt" = {
                path = "/var/lib/blackmatter/pki/etcd.crt";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/etcd/key" = {
                path = "/var/lib/blackmatter/pki/etcd.key";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
              "kubernetes/kubelet/key" = {
                path = "/var/lib/blackmatter/pki/kubelet.key";
                sopsFile = "${secretsFile}/secrets.yaml";
                mode = "0444";
                owner = "root";
                group = "root";
              };
            };
          };
        } {};
      }
      // container.defaults;
  };
  system.activationScripts.kubernetesPkiDir = {
    text = ''
      mkdir -p /var/lib/blackmatter/pki
      chown root:root /var/lib/blackmatter
      chmod 755 /var/lib/blackmatter
    '';
  };
  networking.nat = {
    enable = true;
    internalInterfaces = [host.bridge];
  };
  networking.bridges.${host.bridge}.interfaces = [];
  networking.interfaces.${host.bridge} = {
    ipv4.addresses = [
      {
        address = host.gateway;
        prefixLength = host.prefix;
      }
    ];
    ipv6.addresses = [];
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
