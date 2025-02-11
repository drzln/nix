{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.minio;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    name = mkOption {
      type = types.str;
    };

    user = mkOption {
      type = types.str;
    };

    group = mkOption {
      type = types.str;
    };

    port = mkOption {
      type = types.int;
      default = 3000;
    };

    paths = {
      home = mkOption {
        type = types.str;
      };
      data = mkOption {
        type = types.str;
        default = "/home/${cfg.user}/${cfg.paths.home}/data";
      };
    };

    minio = {
      root = {
        user = mkOption {
          type = types.str;
          default = "admin";
        };
        password = mkOption {
          type = types.str;
          default = "letmein1234!";
        };
      };
      console = {
        port = mkOption {
          type = types.int;
          default = 10001;
        };
      };
      address = {
        port = mkOption {
          type = types.int;
          default = 10002;
        };
      };
    };

    data = mkOption {
      type = types.str;
      default = "${cfg.paths.home}/data";
    };

    prepare = mkOption {
      type = types.package;
      default = pkgs.writeScriptBin "prepare" ''
        set -x
        set -e
        ${pkgs.coreutils}/bin/mkdir -p /home/${cfg.user}/${cfg.paths.home} 
        ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} /home/${cfg.user}/${cfg.paths.home}
        ${pkgs.coreutils}/bin/mkdir -p /home/${cfg.user}/${cfg.paths.data} 
        ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} /home/${cfg.user}/${cfg.paths.data}
      '';
    };

    start = mkOption {
      type = types.package;
      default = pkgs.writeScriptBin "start" ''
        export MINIO_ROOT_USER=${cfg.minio.root.user}
        export MINIO_ROOT_PASSWORD=${cfg.minio.root.password}
        ${pkgs.minio}/bin/minio server ${cfg.paths.data} \
          --console-address ":${builtins.toString cfg.minio.console.port}" \
        	--address ":${builtins.toString cfg.minio.address.port}"
      '';
    };

    network = {
      private = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
in
{
  imports = [ ../goomba_user_service ];
  options.blackmatter.components.microservices.minio = interface;

  config = mkMerge [
    (mkIf cfg.enable {
      blackmatter.components.microservices.goomba-user-service = {
        enable = cfg.enable;
        name = cfg.name;
        prepare = cfg.prepare;
        start = cfg.start;
        network = cfg.network;
        user = cfg.user;
        group = cfg.group;
        paths = cfg.paths;
      };
    })
  ];
}
