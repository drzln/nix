{ lib, pkgs, config, ... }:
with lib;

let
  # Access ProxySQL configuration from the user config
  n = config.blackmatter.components.microservices.proxysql;

  # Defaults for development mode
  devDefaults = {
    bind_addr = "127.0.0.1";
    data_dir = "/tmp/proxysql";
    client = true;
  };

  # Defaults for production mode
  prodDefaults = {
    bind_addr = "0.0.0.0";
    data_dir = "/var/lib/proxysql";
    client = false;
    server = true;
  };

  # Merge dev/prod defaults with any user-supplied config plus explicit port setting
  finalProxySQLConfig = mkMerge [
    (if n.mode == "dev" then devDefaults else prodDefaults)
    n.extraConfig
    {
      ports = {
        http = n.port;
      };
    }
  ];

  # Helper to safely get an attribute or use a fallback
  get = name: fallback:
    if finalProxySQLConfig ? name then finalProxySQLConfig.${name} else fallback;

  # Default dev command
  defaultDevCommand = ''
    ${n.package}/bin/proxysql agent -dev \
      -bind=${get "bind_addr" "127.0.0.1"} \
      -data-dir=${get "data_dir" "/tmp/proxysql"}
  '';

  # Default prod command
  defaultProdCommand = ''
    ${n.package}/bin/proxysql agent \
      -bind=${get "bind_addr" "0.0.0.0"} \
      -data-dir=${get "data_dir" "/var/lib/proxysql"}
  '';

  # Final command line (honor user override if provided)
  finalCommand =
    if n.command != "" then
      n.command
    else if n.mode == "dev" then
      defaultDevCommand
    else
      defaultProdCommand;

in
{
  options = {
    blackmatter.components.microservices.proxysql = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ProxySQL service.";
      };

      mode = mkOption {
        type = types.enum [ "dev" "prod" ];
        default = "dev";
        description = "ProxySQL mode: 'dev' or 'prod'.";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra ProxySQL configuration merged into dev/prod defaults.";
      };

      command = mkOption {
        type = types.str;
        default = "";
        description = ''
          If non-empty, override the command to start ProxySQL.
          Otherwise, a dev/prod-appropriate default is used.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 4646;
        description = ''
          TCP port on which ProxySQL listens.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.proxysql;
        description = "The ProxySQL derivation to use.";
      };

      namespace = mkOption {
        type = types.str;
        default = "default";
        description = "Namespace for the proxysql systemd service name.";
      };
    };
  };

  config = mkIf n.enable {
    # Optionally, write final JSON config (if needed by ProxySQL)
    # For demonstration, we output it to /etc/proxysql.d/config.json
    environment.etc."proxysql.d/config.json".text = builtins.toJSON finalProxySQLConfig;

    # Create systemd service for ProxySQL
    systemd.services."${n.namespace}-proxysql" = {
      description = "${n.namespace} ProxySQL Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = finalCommand;
    };
  };
}
