{ lib, pkgs, config, ... }:
with lib;

let
  # Access supervisord configuration
  s = config.blackmatter.components.microservices.supervisord;

  # Paths for configuration and logging
  supervisordConfigDir = "/etc/supervisord/config.d/groups";
  logDir = "/var/log/supervisor";
  log = "${logDir}/supervisord.log";
  pidDir = "/var/run/supervisor";
  pid = "${pidDir}/supervisord.pid";

  # Supervisor main configuration file
  supervisordMainConfig = ''
    [supervisord]
    logfile=${log}
    logfile_maxbytes=50MB
    logfile_backups=7
    pidfile=${pid}
    nodaemon=true ; Prevent Supervisor from exiting when no programs are managed
    user=${s.user or "root"}

    [include]
    files = ${supervisordConfigDir}/*/*.conf

    [inet_http_server]
    port=*:9001                 ; Accessible on all network interfaces on port 9001

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl=http://127.0.0.1:9001 ; Connect to the HTTP server
  '';
in
{
  options = {
    blackmatter.components.microservices.supervisord = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable supervisord to manage application groups.";
      };

      groups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of group names to be managed by supervisord.";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "Default user for supervisord-managed applications.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.python312Packages.supervisor;
        description = "The supervisord package to use.";
      };

      namespace = mkOption {
        type = types.str;
        default = "default";
        description = "Namespace for the supervisord service name.";
      };
    };
  };

  config = mkIf s.enable {
    # Write the main supervisord configuration
    environment.etc."supervisord/supervisord.conf".text = supervisordMainConfig;
    systemd.services."${s.namespace or "default"}-supervisord" = {
      description = "${s.namespace or "default"} Supervisord Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "root";
        ExecStart = "${s.package or pkgs.python312Packages.supervisor}/bin/supervisord -c /etc/supervisord/supervisord.conf";
        ExecStop = "${s.package or pkgs.python312Packages.supervisor}/bin/supervisorctl shutdown";
        Restart = "on-failure";
      };
    };
  };
}

