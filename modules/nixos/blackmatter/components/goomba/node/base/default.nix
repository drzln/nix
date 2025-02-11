# settings global to goomba nodes
# a node is a set of containers running a microservice together
# and typically in prod would have only ingress/egress in 80/443
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.goomba.node.base;
in
{
  options.blackmatter.components.goomba.node.base = {
    enable = mkEnableOption "enable goomba base settings for every node";

    ssh.enable = mkEnableOption "enable ssh";

    mode.debug = mkOption {
      type = types.bool;
    };

    mode.dev = mkOption {
      type = types.bool;
    };

    dns.addresses = mkOption {
      type = types.listOf types.str;
    };

    user = {
      name = mkOption {
        type = types.str;
      };

      uid = mkOption {
        type = types.int;
      };

      ssh.pubkey = mkOption {
        type = types.str;
      };
    };

    host = {
      name = mkOption {
        type = types.str;
      };
      gateway = mkOption {
        type = types.str;
      };
      ip = {
        local = mkOption {
          type = types.str;
        };
        prefix = mkOption {
          type = types.int;
        };
      };
    };
  };

  config = mkMerge [
    # if we are in debug mode do these things
    (mkIf (cfg.enable && cfg.mode.debug) {
      environment.systemPackages = with pkgs; [ dig nmap ];
    })

    # if we are in dev mode do these things
    (mkIf (cfg.enable && cfg.mode.debug) {
      networking.firewall.enable = false;
    })

    (mkIf cfg.enable {
      system.stateVersion = "24.11";

      # add service dns addesses to each node to speak to each other
      # supports ssh ${component}.${domain}
      services.dnsmasq.enable = true;
      services.dnsmasq.resolveLocalQueries = true;
      services.dnsmasq.settings.address = cfg.dns.addresses;

      # permit user level ssh but no root
      # user will be a privileged managed user
      # typically your local user if this is a local
      # dev environment and an "automation" user in other
      # places.
      services.openssh.enable = cfg.ssh.enable;
      services.openssh.settings.PermitRootLogin = "no";
      services.openssh.settings.PasswordAuthentication = false;

      networking.domain = cfg.domain;
      networking.useDHCP = false;
      networking.hostName = cf.host.name;
      networking.defaultGateway = cfg.host.gateway;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = cfg.host.ip.local;
        prefixLength = cfg.host.ip.prefix;
      }];

      # ensure root has no keys
      users.users.root.openssh.authorizedKeys.keys = [ ];

      # configure a management user with pubkey access
      # and passwordless sudo
      users.users."${cfg.user.name}" = {
        isSystemUser = false;
        isNormalUser = true;
        uid = cfg.user.uid;
        group = cfg.user.name;
        shell = pkgs.bash;
        createHome = true;
        openssh.authorizedKeys.keys = [ cfg.user.ssh.pubkey ];
      };
      users.groups."${cfg.user.name}".gid = cfg.user.uid;
      security.sudo.extraConfig = ''${cfg.user.name} ALL=(ALL) NOPASSWD:ALL'';
    })
  ];
}
