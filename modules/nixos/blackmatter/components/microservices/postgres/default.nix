{ lib, pkgs, config, ... }:
with lib;

let
  # Access PostgreSQL configuration from the user config
  p = config.blackmatter.components.microservices.postgres;

  # Defaults for development mode
  devDefaults = {
    listen_addresses = "localhost";
    data_dir = "/tmp/postgres";
    port = 5432;
    max_connections = 20;
  };

  # Defaults for production mode
  prodDefaults = {
    listen_addresses = "*";
    data_dir = "/var/lib/postgresql/data";
    port = 5432;
    max_connections = 100;
  };

  # Merge dev/prod defaults with any user-supplied config
  finalPostgresConfig = mkMerge [
    (if p.mode == "dev" then devDefaults else prodDefaults)
    p.extraConfig
    {
      port = p.port;
    }
  ];

  # Helper to safely get an attribute or use a fallback
  get = name: fallback:
    if finalPostgresConfig ? name then finalPostgresConfig.${name} else fallback;

  # Default dev command
  defaultDevCommand = ''
    mkdir -p ${get "data_dir" "/tmp/postgres"}
    ${p.package}/bin/initdb -D ${get "data_dir" "/tmp/postgres"} --username=postgres --encoding=UTF8 || true
    ${p.package}/bin/postgres -D ${get "data_dir" "/tmp/postgres"} \
      -h ${get "listen_addresses" "localhost"} \
      -p ${get "port" 5432}
  '';

  # Default prod command
  defaultProdCommand = ''
    ${p.package}/bin/postgres -D ${get "data_dir" "/var/lib/postgresql/data"} \
      -h ${get "listen_addresses" "*"} \
      -p ${get "port" 5432}
  '';

  # Final command line (honor user override if provided)
  finalCommand =
    if p.command != "" then
      p.command
    else if p.mode == "dev" then
      defaultDevCommand
    else
      defaultProdCommand;

in
{
  options = {
    blackmatter.components.microservices.postgres = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable PostgreSQL service.";
      };

      mode = mkOption {
        type = types.enum [ "dev" "prod" ];
        default = "dev";
        description = "PostgreSQL mode: 'dev' or 'prod'.";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra PostgreSQL configuration merged into dev/prod defaults.";
      };

      command = mkOption {
        type = types.str;
        default = "";
        description = ''
          If non-empty, override the command to start PostgreSQL.
          Otherwise, a dev/prod-appropriate default is used.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 5432;
        description = ''
          Port on which PostgreSQL listens.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.postgresql_15;
        description = "The PostgreSQL derivation to use.";
      };

      namespace = mkOption {
        type = types.str;
        default = "default";
        description = "Namespace for the PostgreSQL systemd service name.";
      };
    };
  };

  config = mkIf p.enable {
    # Optionally, write final configuration to /etc/postgresql/postgresql.conf
    environment.etc."postgresql/postgresql.conf".text = builtins.toJSON finalPostgresConfig;

    # Create systemd service for PostgreSQL
    systemd.services."${p.namespace}-postgres" = {
      description = "${p.namespace} PostgreSQL Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = finalCommand;
        ExecStop = "${p.package}/bin/pg_ctl stop -D ${get "data_dir" "/var/lib/postgresql/data"}";
        Restart = "on-failure";
      };
    };

    # Ensure the data directory exists
    systemd.tmpfiles.rules = [
      "d ${get "data_dir" "/var/lib/postgresql/data"} 0755 postgres postgres -"
    ];
  };
}

