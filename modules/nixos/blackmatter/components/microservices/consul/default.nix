{ lib, pkgs, config, ... }:
with lib;

let
  c = config.blackmatter.components.microservices.consul;

  # Defaults for development mode
  devDefaults = {
    bind_addr = "127.0.0.1";
    server = false;
    data_dir = "/tmp/consul";
    ui = true;
  };

  # Defaults for production mode
  prodDefaults = {
    bind_addr = "0.0.0.0";
    server = true;
    data_dir = "/var/lib/consul";
    ui = false;
  };

  # Merge dev/prod defaults with any user-supplied config, plus an explicit port setting
  finalConsulConfig = mkMerge [
    (if c.mode == "dev" then devDefaults else prodDefaults)
    c.extraConfig
    {
      ports = {
        http = c.port;
      };
    }
  ];

  # Helper to safely get an attribute or use a fallback
  get = name: fallback:
    if finalConsulConfig ? name then finalConsulConfig.${name} else fallback;

  # Default dev command
  defaultDevCommand = ''
    ${c.package}/bin/consul agent -dev \
      -bind=${get "bind_addr" "127.0.0.1"} \
      --data-dir=${get "data_dir" "/tmp/consul"} \
      --ui
  '';

  # Default prod command
  defaultProdCommand = ''
    ${c.package}/bin/consul agent -server \
      -bind=${get "bind_addr" "0.0.0.0"} \
      -config-dir=/etc/consul.d \
      --data-dir=${get "data_dir" "/var/lib/consul"}
  '';

  # Final command line (honor user override if provided)
  finalCommand =
    if c.command != "" then
      c.command
    else if c.mode == "dev" then
      defaultDevCommand
    else
      defaultProdCommand;

in
{
  options = {
    blackmatter.components.microservices.consul = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Consul service.";
      };

      mode = mkOption {
        type = types.enum [ "dev" "prod" ];
        default = "dev";
        description = "Consul mode: 'dev' or 'prod'.";
      };

      namespace = mkOption {
        type = types.str;
        default = "default";
        description = "Namespace for the Consul systemd service name.";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra Consul configuration merged into dev/prod defaults.";
      };

      command = mkOption {
        type = types.str;
        default = "";
        description = ''
          If non-empty, completely override the command to start Consul.
          Otherwise, a dev/prod-appropriate default is used.
        '';
      };

      # NEW: Overridable Consul HTTP port (default 8500).
      port = mkOption {
        type = types.int;
        default = 8500;
        description = ''
          HTTP port on which Consul listens. 
          By default, this is 8500.
        '';
      };

      # NEW: Package option to let users specify which Consul derivation to use.
      package = mkOption {
        type = types.package;
        default = pkgs.consul;
        description = ''
          The Consul derivation to use. Defaults to the system's "pkgs.consul".
        '';
      };
    };
  };

  config = mkIf c.enable {
    # Write final JSON config to /etc/consul.d/config.json
    environment.etc."consul.d/config.json".text = builtins.toJSON finalConsulConfig;

    # Create systemd service
    systemd.services."${c.namespace}-consul" = {
      description = "${c.namespace} Consul Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = finalCommand;
    };
    services.dnsmasq.settings = {
      address = [ "/${c.namespace}-consul.local/127.0.0.1" ];
    };
  };
}
