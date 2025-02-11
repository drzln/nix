{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.goomba-user-service;

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

    paths = {
      home = mkOption {
        type = types.str;
      };
      data = mkOption {
        type = types.str;
        default = "/home/${cfg.user}/${cfg.paths.home}/data";
      };
    };

    shell = {
      name = mkOption {
        type = types.str;
        default = "bash";
      };
      pkg = mkOption {
        type = types.package;
        default = pkgs."${cfg.shell.name}";
      };
    };

    prepare = mkOption {
      type = types.package;
    };

    start = mkOption {
      type = types.package;
    };

    network = {
      private = mkOption {
        type = types.bool;
        default = false;
      };
    };

    container = {
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

      prefix = mkOption {
        type = types.str;
        default = ".goomba-container-${cfg.name}";
      };

      directory = mkOption {
        type = types.str;
        default = "/home/${cfg.user}/${cfg.container.prefix}";
      };

      start = mkOption {
        type = types.package;
        default = pkgs.writeShellScriptBin "start" ''
          ${pkgs.systemd}/bin/systemd-nspawn \
            --private-users \
            --private-network \
            -D ${cfg.container.directory} \
            ${cfg.shell.pkg}/bin/${cfg.shell.name} ${cfg.start}/bin/start
        '';
      };
    };
  };
in
{
  options.blackmatter.components.microservices.goomba-user-service = interface;

  config = lib.mkMerge [

    (lib.mkIf (cfg.enable && cfg.network.private) {
      home.file."${cfg.container.prefix}/.placeholder" = {
        text = "";
      };

      systemd.user.services."${cfg.name}-container-prepare" = {
        Service = {
          Type = "oneshot";
          ExecStart = "${cfg.shell.pkg}/bin/${cfg.shell.name} ${cfg.container.prepare}/bin/prepare";
          RemainAfterExit = true;
        };
      };

      systemd.user.services."${cfg.name}-container-task" = {
        Unit = {
          After = [ "${cfg.name}-container-prepare.target" ];
        };
        Service = {
          ExecStart = "${cfg.shell.pkg}/bin/${cfg.shell.name} ${cfg.container.start}/bin/start";
        };
      };
    })

    (lib.mkIf (cfg.enable && ! cfg.network.private) {

      systemd.user.services."${cfg.name}-prepare" = {
        Service = {
          Type = "oneshot";
          ExecStart = "${cfg.shell.pkg}/bin/${cfg.shell.name} ${cfg.start}/bin/start";
          RemainAfterExit = true;
        };
      };

      systemd.user.services."${cfg.name}-task" = {
        Unit = {
          After = [ "${cfg.name}-prepare.service" ];
        };
        Service = {
          ExecStart = "${cfg.shell.pkg}/bin/${cfg.shell.name} ${cfg.start}/bin/start";
        };
      };
    })
  ];
}

