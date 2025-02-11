{ lib, pkgs, config, ... }:
with lib;

let
  # Access Nomad configuration from the user config
  n = config.blackmatter.components.microservices.nomad;

  # Defaults for development mode
  devDefaults = {
    bind_addr = "127.0.0.1";
    data_dir = "/tmp/nomad";
    client = true;
  };

  # Defaults for production mode
  prodDefaults = {
    bind_addr = "0.0.0.0";
    data_dir = "/var/lib/nomad";
    client = false;
    server = true;
  };

  # Merge dev/prod defaults with any user-supplied config plus explicit port setting
  finalNomadConfig = mkMerge [
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
    if finalNomadConfig ? name then finalNomadConfig.${name} else fallback;

  # Default dev command
  defaultDevCommand = ''
    ${n.package}/bin/nomad agent -dev \
      -bind=${get "bind_addr" "127.0.0.1"} \
      -data-dir=${get "data_dir" "/tmp/nomad"}
  '';

  # Default prod command
  defaultProdCommand = ''
    ${n.package}/bin/nomad agent \
      -bind=${get "bind_addr" "0.0.0.0"} \
      -data-dir=${get "data_dir" "/var/lib/nomad"}
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
    blackmatter.components.microservices.nomad = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nomad service.";
      };

      mode = mkOption {
        type = types.enum [ "dev" "prod" ];
        default = "dev";
        description = "Nomad mode: 'dev' or 'prod'.";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra Nomad configuration merged into dev/prod defaults.";
      };

      command = mkOption {
        type = types.str;
        default = "";
        description = ''
          If non-empty, override the command to start Nomad.
          Otherwise, a dev/prod-appropriate default is used.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 4646;
        description = ''
          HTTP port on which Nomad listens.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.nomad;
        description = "The Nomad derivation to use.";
      };

      namespace = mkOption {
        type = types.str;
        default = "default";
        description = "Namespace for the nomad systemd service name.";
      };
    };
  };

  config = mkIf n.enable {
    # Optionally, write final JSON config (if needed by Nomad)
    # For demonstration, we output it to /etc/nomad.d/config.json
    environment.etc."nomad.d/config.json".text = builtins.toJSON finalNomadConfig;

    # Create systemd service for Nomad
    systemd.services."${n.namespace}-nomad" = {
      description = "${n.namespace} Nomad Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = finalCommand;
    };
  };
}
