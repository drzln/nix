{ lib, config, pkgs, ... }:
with lib;
let
  create-bucket-script = pkgs.writeShellScriptBin "create-bucket.sh" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Configure your variables
    BUCKET="main"  # Adjust as needed
    ALIAS="main"   # The alias name we will use with mc
    MINIO_URL="http://minio.attic.local.pleme.io:9000"
    MINIO_ACCESS_KEY="admin"  # Replace with your actual key
    MINIO_SECRET_KEY="letmein1234!"

    # Loop until MinIO is ready to respond. (You might want to add a timeout.)
    echo "Waiting for MinIO to become available..."
    until ${pkgs.minio-client}/bin/mc ls >/dev/null 2>&1; do
      sleep 5
    done
    sleep 30
    echo "MinIO is up."

    # Set the alias for the MinIO client
    ${pkgs.minio-client}/bin/mc alias set $ALIAS $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

    # Create the bucket if it doesn't exist
    if ! ${pkgs.minio-client}/bin/mc ls $ALIAS/$BUCKET > /dev/null 2>&1; then
      echo "Creating bucket '$BUCKET'..."
      ${pkgs.minio-client}/bin/mc mb $ALIAS/$BUCKET
    else
      echo "Bucket '$BUCKET' already exists."
    fi
  '';

  cfg = config.blackmatter.components.microservices.attic;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Attic microservice.";
    };

    run-create-bucket = mkOption {
      type = types.bool;
      default = false;
      description = "If true, a one-shot service will run to create the main bucket in MinIO.";
    };

    dns-server = mkOption {
      type = types.str;
      description = "DNS server option.";
    };

    dns-local-addresses = mkOption {
      type = types.anything;
      description = "Local addresses for DNS.";
    };

    storage = mkOption {
      type = types.enum [ "local" "s3" ];
      default = "local";
      description = "Storage backend type. 'local' uses a local filesystem directory; 's3' uses S3-style storage (with MinIO in this case).";
    };

    minio = {
      region = mkOption {
        type = types.str;
        default = "us-east-1";
      };
      endpoint = mkOption {
        default = "http://minio.attic.local.pleme.io:9000";
      };
      access-key = mkOption {
        default = "admin";
      };
      secret-key = mkOption {
        default = "letmein1234!";
      };
      default-bucket = mkOption {
        default = "main";
      };
      key = mkOption {
        default = "/attic/nix/cache";
      };
    };
  };

  # Base settings that are common regardless of storage type.
  baseSettings = {
    listen = "[::]:8080";
    chunking.min-size = 16384;
    chunking.avg-size = 65536;
    chunking.max-size = 262144;
    chunking."nar-size-threshold" = 131072;
    jwt = {
      signing = {
        token-hs256-secret-base64 = lib.fileContents "/home/luis/.secrets/attic/jwt/token";
      };
    };
  };

  # Select storage configuration based on the new option.
  storageConfig =
    if cfg.storage == "s3" then {
      # S3 (MinIO) configuration
      storage.type = "s3";
      storage.bucket = cfg.minio.default-bucket;
      storage.region = cfg.minio.region;
      storage.endpoint = cfg.minio.endpoint;
      storage.access-key = cfg.minio.access-key;
      storage.secret-key = cfg.minio.secret-key;
      storage.key = cfg.minio.key;
    } else {
      # Local storage configuration
      storage.type = "local";
      storage.path = "/var/lib/attic";
    };
in
{
  options.blackmatter.components.microservices.attic = interface;

  config = mkMerge [
    (mkIf cfg.enable {
      services.atticd.enable = cfg.enable;
      environment.etc."attic/env" = {
        text = ''
          ATTIC_SERVER_TOKEN_RS256_SECRET=${lib.fileContents "/home/luis/.secrets/attic/key"}
        '';
        mode = "0400"; # Restrict permissions to root only
      };
      services.atticd.environmentFile = "/etc/attic/env";
      services.atticd.settings = mkMerge [ baseSettings storageConfig ];
    })
    (mkIf (cfg.enable && cfg.run-create-bucket) {
      systemd.services.bucket = {
        description = "Create main bucket in MinIO";
        before = [ "atticd.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${create-bucket-script}/bin/create-bucket.sh";
          Environment = "PATH=/run/current-system/sw/bin:${pkgs.minio-client}/bin:${pkgs.glibc.out}/bin";
        };
        wantedBy = [ "multi-user.target" ];
      };
    })
  ];
}
