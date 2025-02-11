{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.programs.joplin;

  joplin-desktop = pkgs.stdenv.mkDerivation rec {
    pname = "joplin-desktop";
    version = "2.12.18";
    src = pkgs.fetchurl {
      url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}.AppImage";
      hash = "sha256-abc123..."; # Update with actual hash
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 $src $out/bin/joplin-desktop
      wrapProgram $out/bin/joplin-desktop --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.fuse ]}
    '';
  };

  joplin-cli = pkgs.stdenv.mkDerivation rec {
    pname = "joplin-cli";
    version = "2.12.18";
    src = pkgs.fetchurl {
      url = "https://github.com/laurent22/joplin/releases/download/v${version}/joplin-${version}.tar.gz";
      hash = "sha256-def456..."; # Update with actual hash
    };

    buildInputs = [ pkgs.nodejs ];

    installPhase = ''
      mkdir -p $out/{bin,lib}
      cp -r $src/* $out/lib/
      ln -s $out/lib/joplin $out/bin/joplin
    '';
  };

in
{
  options.programs.joplin = {
    enable = mkEnableOption "Joplin note-taking application";

    desktop.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Joplin desktop application";
    };

    cli.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Joplin CLI client";
    };

    sync = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable automatic synchronization";
      };

      interval = mkOption {
        type = types.str;
        default = "hourly";
        description = "Synchronization interval";
      };

      target = mkOption {
        type = types.enum [ "dropbox" "onedrive" "nextcloud" "webdav" "filesystem" ];
        default = "nextcloud";
        description = "Synchronization target";
      };

      settings = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Synchronization configuration";
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Joplin configuration settings";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (optional cfg.desktop.enable joplin-desktop) ++
      (optional cfg.cli.enable joplin-cli);

    xdg.configFile."joplin/config.json" = mkIf (cfg.settings != { }) {
      text = builtins.toJSON cfg.settings;
    };

    systemd.user.services.joplin-sync = mkIf cfg.sync.enable {
      Unit.Description = "Joplin Synchronization Service";
      Service = {
        Type = "oneshot";
        ExecStart = "${joplin-cli}/bin/joplin sync";
        Environment = [
          "JOPLIN_CONFIG_DIR=${config.xdg.configHome}/joplin"
        ];
      };
    };

    systemd.user.timers.joplin-sync = mkIf cfg.sync.enable {
      Unit.Description = "Timer for Joplin synchronization";
      Timer = {
        OnUnitActiveSec = cfg.sync.interval;
        OnBootSec = "5m";
        Unit = "joplin-sync.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    xdg.mimeApps = mkIf cfg.desktop.enable {
      enable = true;
      defaultApplications = {
        "application/x-joplin" = "joplin.desktop";
      };
    };

    home.sessionVariables = {
      JOPLIN_CONFIG_DIR = "${config.xdg.configHome}/joplin";
    };
  };
}
