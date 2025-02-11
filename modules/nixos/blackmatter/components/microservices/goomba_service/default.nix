{ lib, pkgs, config, ... }:
with lib;
let
  s = config.blackmatter.components.microservices.goomba_service;
in
{
  config = mkIf s.enable {
    systemd.services."${s.name}" = {
      # wantedBy = [ "multi-user-target" ];
      serviceConfig.ExecStart = s.command;
    };
  };

  options = {
    blackmatter = {
      components = {
        microservices = {
          goomba_service = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };

            name = mkOption {
              type = types.str;
            };

            user = mkOption {
              type = types.str;
            };

            command = mkOption {
              type = types.str;
            };

            port = mkOption {
              type = types.int;
              default = 0;
            };

            package = mkOption {
              type = types.package;
            };

          };
        };
      };
    };
  };
}
