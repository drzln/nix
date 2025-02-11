{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.minio;

  interface = {
    enable = mkEnableOption "flip on minio";

    data-dir = mkOption {
      type = types.listOf types.str;
      default = [ "/var/lib/minio" ];
    };

    root-credentials-file = mkOption {
      type = types.package;
      default = pkgs.writeText "creds" ''
        MINIO_ROOT_USER=admin
        MINIO_ROOT_PASSWORD=letmein1234!
      '';
    };

    host = mkOption {
      type = types.str;
      default = "minio";
    };

    listen-address = mkOption {
      type = types.str;
      default = ":9000";
    };

    console-address = mkOption {
      type = types.str;
      default = ":9001";
    };
  };
in
{
  options.blackmatter.components.microservices.minio = interface;

  config = mkMerge [
    (mkIf cfg.enable {
      services.minio = {
        enable = cfg.enable;
        dataDir = cfg.data-dir;
        rootCredentialsFile = cfg.root-credentials-file;
        listenAddress = cfg.listen-address;
        consoleAddress = cfg.console-address;
      };
    })
  ];
}
