{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.blackmatter.components.search.searxng;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SearxNG service";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.searxng;
      description = "SearxNG package to use";
    };

    user = mkOption {
      type = types.str;
      default = "searxng";
      description = "User under which SearxNG runs";
    };

    group = mkOption {
      type = types.str;
      default = "searxng";
      description = "Group under which SearxNG runs";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/searxng";
      description = "Directory for SearxNG state, logs, and plugins";
    };

    port = mkOption {
      type = types.int;
      default = 8888;
      description = "Port on which SearxNG listens";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to which SearxNG binds";
    };

    secretKey = mkOption {
      type = types.str;
      default = "your-secret-key";
      description = "Secret key for SearxNG";
    };

    runInUwsgi = mkOption {
      type = types.bool;
      default = false;
      description = "Run SearxNG within uWSGI";
    };

    uwsgiConfig = mkOption {
      type = types.attrsOf types.str;
      default = {
        socket = "/run/searxng/searxng.sock";
        http = ":8888";
        chmod-socket = "660";
      };
      description = "uWSGI configuration for SearxNG";
    };

    redis = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Redis for SearxNG";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.redis;
        description = "Redis package to use";
      };
      createLocally = mkOption {
        type = types.bool;
        default = false;
        description = "Configure a local Redis server for SearxNG";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "SearxNG settings (overrides defaults if non-empty)";
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        search = {
          searxng = interface;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.searx = {
        enable = true;
        package = cfg.package;
        user = cfg.user;
        group = cfg.group;
        stateDir = cfg.stateDir;
        port = cfg.port;
        settings = cfg.settings;
        runInUwsgi = cfg.runInUwsgi;
        uwsgiConfig = cfg.uwsgiConfig;
        redisCreateLocally = cfg.redis.createLocally;
      };

      # (mkIf cfg.redis.enable {
      # services.redis = {
      #   enable = true;
      #   package = cfg.redis.package;
      # };
    })
  ];
}

