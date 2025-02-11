{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.blackmatter.components.project_management.redmine;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Redmine service";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.redmine;
      description = "Redmine package to use";
    };

    user = mkOption {
      type = types.str;
      default = "redmine";
      description = "User under which Redmine runs";
    };

    group = mkOption {
      type = types.str;
      default = "redmine";
      description = "Group under which Redmine runs";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/redmine";
      description = "Directory for Redmine state, logs, and plugins";
    };

    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Port on which Redmine listens";
    };

    database = {
      type = mkOption {
        type = types.str;
        default = "postgresql";
        description = "Type of database backend (e.g., 'postgresql' or 'mysql')";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = "Database host";
      };

      name = mkOption {
        type = types.str;
        default = "redmine";
        description = "Database name";
      };

      user = mkOption {
        type = types.str;
        default = "redmine";
        description = "Database user";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/var/lib/redmine/db_password";
        description = "Path to file containing the database password";
      };

      socket = mkOption {
        type = types.str;
        default = "/run/postgresql",
        description = "Database socket path";
      };

      createLocally = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to create the database locally";
      };
    };

    components = {
      git = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Git integration";
      };

      subversion = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Subversion integration";
      };

      mercurial = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Mercurial integration";
      };

      cvs = mkOption {
        type = types.bool;
        default = false;
        description = "Enable CVS integration";
      };

      breezy = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Breezy integration";
      };

      imagemagick = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ImageMagick support";
      };

      ghostscript = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Ghostscript support";
      };

      minimagick_font_path = mkOption {
        type = types.str;
        default = "/run/current-system/sw/share/fonts/truetype/dejavu/DejaVuSans.ttf";
        description = "Path to the font used by MiniMagick";
      };
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        project_management = {
          redmine = interface;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.redmine = {
        enable = true;
        package = cfg.package;
        user = cfg.user;
        group = cfg.group;
        stateDir = cfg.stateDir;
        port = cfg.port;
        database = {
          type = cfg.database.type;
          host = cfg.database.host;
          name = cfg.database.name;
          user = cfg.database.user;
          passwordFile = cfg.database.passwordFile;
          socket = cfg.database.socket;
          createLocally = cfg.database.createLocally;
        };
        components = {
          git = cfg.components.git;
          subversion = cfg.components.subversion;
          mercurial = cfg.components.mercurial;
          cvs = cfg.components.cvs;
          breezy = cfg.components.breezy;
          imagemagick = cfg.components.imagemagick;
          ghostscript = cfg.components.ghostscript;
          minimagick_font_path = cfg.components.minimagick_font_path;
        };
      };
    })
  ];
}

