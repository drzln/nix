{
  # pkgs,
  # requirements,
  ...
}: let
  # This configuration configures the host then configures any downstream
  # containers.
  host = {
    bridge = "internal-br-1";
    gateway = "10.3.0.1";
    prefix = 24;
  };
  # data = import ../goomba-data.nix {};
  # name = "felipenetes";
  # domain_prefix = "local.pleme.io";
  # domain = "${name}.${domain_prefix}";
  # state.version = "24.11";
  # user.name = "kubeadm";
  # user.uid = 999;
  # user.ssh.pubkey = ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo'';
  # ip.space = {
  #   main = {
  #     prefix = prefix;
  #     local = "10.3.0.2";
  #   };
  #
  #   # minio = {
  #   #   prefix = 24;
  #   #   local = "10.3.0.3";
  #   # };
  #
  #   # haproxy = {
  #   #   local = "10.2.0.4";
  #   #   prefix = 24;
  #   # };
  #   # dnsmasq = {
  #   #   prefix = 24;
  #   #   local = "10.1.0.3";
  #   # };
  # };
  # dns.addresses = [
  #   "/main.${domain}/${ip.space.main.local}"
  #   "/minio.${domain}/${ip.space.minio.local}"
  #   "/haproxy.${domain}/${ip.space.haproxy.local}"
  #   # "/dnsmasq.${domain}/${ip-space.dnsmasq.local}"
  # ];
  # nixos-common-module = {
  #   lib,
  #   config,
  #   pkgs,
  #   ...
  # }: {
  #   imports = [
  #     requirements.inputs.home-manager.nixosModules.home-manager
  #   ];
  #   system.stateVersion = state.version;
  #   # permit user level ssh but no root
  #   # user will be a privileged managed user
  #   # typically your local user if this is a local
  #   # dev environment and an "automation" user in other
  #   # places.
  #   services.openssh.enable = true;
  #   services.openssh.settings.PermitRootLogin = "no";
  #   services.openssh.settings.PasswordAuthentication = false;
  #   # add service dns addesses to each node to speak to each other
  #   # supports ssh ${component}.${domain}
  #   services.dnsmasq.enable = true;
  #   services.dnsmasq.resolveLocalQueries = true;
  #   # services.dnsmasq.settings.address = dns.addresses;
  #   services.dnsmasq.settings.server = [
  #     gateway
  #     "8.8.8.8"
  #     "8.8.4.4"
  #   ];
  #
  #   networking.firewall.enable = false;
  #   # networking.domain = domain;
  #   networking.useDHCP = false;
  #   networking.defaultGateway = gateway;
  #   programs.zsh.enable = true;
  #   users.users."${user.name}" = {
  #     isSystemUser = false;
  #     isNormalUser = true;
  #     uid = user.uid;
  #     group = user.name;
  #     shell = pkgs.zsh;
  #     createHome = true;
  #     openssh.authorizedKeys.keys = [user.ssh.pubkey];
  #   };
  #   users.groups."${user.name}".gid = user.uid;
  #   security.sudo.extraConfig = ''${user.name} ALL=(ALL) NOPASSWD:ALL'';
  #   users.users.root.openssh.authorizedKeys.keys = [];
  #   environment.systemPackages = with pkgs; [dig nmap];
  # };
  # container.defaults = {
  #   hostBridge = bridge;
  #   privateNetwork = true;
  #   autoStart = true;
  #   ephemeral = true;
  #   # bindMounts = {
  #   #   "/home/${user.name}" = {
  #   #     hostPath = "/home/${user.name}/.goomba/${name}/mnt/home/${user.name}";
  #   #     isReadOnly = false;
  #   #   };
  #   # };
  # };
  # mk-nixos-container-module = {main}: let
  #   container-module = {
  #     lib,
  #     config,
  #     pkgs,
  #     ...
  #   }: {
  #     imports = [
  #       # ../../../../modules/nixos/blackmatter/components/microservices/${name}
  #       nixos-common-module
  #       main
  #     ];
  #   };
  # in
  #   container-module;
  # home-manager-common-module = {
  #   imports = [
  #     requirements.outputs.homeManagerModules.blackmatter
  #   ];
  #   home.stateVersion = state.version;
  #   home.packages = with pkgs; [vim git];
  #   home.homeDirectory = "/home/${user.name}";
  #   home.sessionVariables = {EDITOR = "vim";};
  #   programs.ssh.enable = true;
  #   programs.ssh.userKnownHostsFile = "/dev/null";
  #   programs.ssh.extraConfig = ''
  #     StrictHostKeyChecking no
  #   '';
  #   blackmatter.enable = true;
  #   blackmatter.components.nvim.enable = true;
  #   blackmatter.components.nvim.package = pkgs.neovim;
  #   blackmatter.components.shell.enable = true;
  #   blackmatter.components.desktop.enable = false;
  #   blackmatter.components.gitconfig.enable = true;
  #   blackmatter.components.gitconfig.email = "luis@pleme.io";
  #   blackmatter.components.gitconfig.user = "luis";
  # };
  # containers = {
  #   haproxy =
  #     {
  #       config = mk-nixos-container-module {
  #         main = {
  #           networking.interfaces.eth0.ipv4.addresses = [
  #             {
  #               address = ip.space.haproxy.local;
  #               prefixLength = ip.space.haproxy.prefix;
  #             }
  #           ];
  #           networking.hostName = "haproxy";
  #           services.haproxy = {
  #             enable = true;
  #             config = ''
  #               global
  #                 # log stdout format raw local0
  #                 maxconn 2000
  #
  #               defaults
  #                 mode http
  #                 log global
  #                 option httplog
  #                 option forwardfor
  #                 timeout connect 5000ms
  #                 timeout client 50000ms
  #                 timeout server 50000ms
  #
  #               frontend http-in
  #                 bind *:80
  #               	# store the original header
  #               	http-request set-var(txn.original_host) req.hdr(Host)
  #
  #                 # Define an ACL that matches requests whose URL path begins with /minio
  #                 acl is_minio_console path_beg /minio
  #                 # acl is_minio_api path_beg /minio/api
  #
  #                 use_backend minio_backend_console if is_minio_console
  #                 # use_backend minio_backend_api if is_minio_api
  #
  #                 # Fallback default backend for other traffic
  #                 # default_backend servers
  #
  #               backend minio_backend_console
  #               	server minio minio.${domain}:9001 check
  #               	http-request set-path %[path,regsub(^/minio/,/)]
  #               	http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
  #               	http-request set-header Host minio.${domain}
  #               	http-request set-header X-Forwarded-Port %[dst_port]
  #               	http-response replace-header Location ^(https?://)minio\.${domain}:9001(.*) /\1%[var(txn.host)]/minio\2
  #               	http-response replace-header Location ^/(.*) /minio/\1
  #
  #               # backend minio_backend_api
  #               # 	server minio minio.lilith.local.pleme.io:9000
  #               # 	# Rewrite Location headers so that if Minio sends a redirect to :9001,
  #               # 	# it is replaced with the external hostname (and port 80 by omission)
  #               # 	# http-response replace-header Location ^(https?://)[^:/]+(:9001)(.*)$ \1haproxy.${domain}\3
  #             '';
  #           };
  #         };
  #       };
  #     }
  #     // container.defaults;
  #
  #   minio =
  #     {
  #       bindMounts = {
  #         "/var/lib/minio" = {
  #           hostPath = "/home/${user.name}/.goomba/${name}/mnt/var/lib/minio";
  #           isReadOnly = false; # set to true if you want a read-only mount
  #         };
  #       };
  #       config = mk-nixos-container-module {
  #         main = {
  #           imports = [
  #             ../../../../modules/nixos/blackmatter/components/microservices/minio
  #           ];
  #           networking.interfaces.eth0.ipv4.addresses = [
  #             {
  #               address = ip.space.minio.local;
  #               prefixLength = ip.space.minio.prefix;
  #             }
  #           ];
  #           networking.hostName = "minio";
  #           blackmatter.components.microservices.minio.enable = true;
  #         };
  #       };
  #     }
  #     // container.defaults;
  #
  #   "${name}" =
  #     ############################################################################
  #     # default container
  #     ############################################################################
  #     {
  #       config = mk-nixos-container-module {
  #         main = {
  #           networking.interfaces.eth0.ipv4.addresses = [
  #             {
  #               address = ip.space.main.local;
  #               prefixLength = ip.space.main.prefix;
  #             }
  #           ];
  #           networking.hostName = "${name}";
  #           home-manager.users.${user.name} = {
  #             imports = [home-manager-common-module];
  #           };
  #         };
  #       };
  #     }
  #     // container.defaults;
  # };
in {
  # inherit containers;

  # host level node settings to run containers the goomba way
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [host.bridge];
  networking.bridges.${host.bridge}.interfaces = []; # Explicitly empty
  networking.interfaces.${host.bridge} = {
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
  # services.dnsmasq.settings.address = dns.addresses;
}
