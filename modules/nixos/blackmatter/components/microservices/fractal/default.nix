{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.desktop.fractal;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Fractal matrix client";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.fractal;
      description = mdDoc "Fractal package to use";
    };

    config = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc ''
        Fractal configuration (GSettings overrides)
        See: https://gitlab.gnome.org/GNOME/fractal/-/blob/main/data/org.gnome.Fractal.gschema.xml
      '';
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable automatic updates";
    };

    security = {
      sandbox = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable bubblewrap sandboxing";
      };
    };

    defaultSettings = {
      org.gnome.Fractal = {
        autostart-on-login = false;
        dark-theme = false;
        send-typing = true;
        default-homeserver = "https://matrix.org";
        encrypt-by-default = false;
      };
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        desktop = {
          fractal = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # GSettings overrides
    services.dconf.settings = {
      "org/gnome/Fractal" = cfg.defaultSettings.org.gnome.Fractal // cfg.config;
    };

    # Auto-update configuration
    systemd.user.services.fractal-updater = mkIf cfg.autoUpdate {
      description = "Fractal Update Checker";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/fractal --check-updates";
      };
      wantedBy = [ "default.target" ];
      startAt = "daily";
    };

    # Sandboxing
    security.bubblewrap = mkIf cfg.security.sandbox {
      enable = true;
      extraPackages = [ cfg.package ];
    };

    # Desktop integration
    services.xserver.desktopManager.gnome3.extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      gtk-enable-primary-paste=false
    '';

    # Notification integration
    services.dbus.packages = [ cfg.package ];
  };
}
