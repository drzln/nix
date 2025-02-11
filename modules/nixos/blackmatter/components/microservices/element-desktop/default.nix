{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.desktop.element;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Element Desktop matrix client";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.element-desktop;
      description = mdDoc "Element Desktop package to use";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable automatic updates";
    };

    config = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = mdDoc ''
        Element configuration (merged into config.json)
        See: https://github.com/vector-im/element-desktop#configjson
      '';
    };

    defaultSettings = {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix-client.matrix.org";
          server_name = "matrix.org";
        };
      };
      brand = "Element";
      disable_3pid_login = false;
      features = {
        feature_pinning = true;
        feature_custom_status = true;
        feature_custom_tags = true;
      };
      settingDefaults = {
        MessageComposerInput.showStickersButton = true;
        MessageComposerInput.showPollsButton = true;
      };
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        desktop = {
          element = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # System-wide configuration file
    environment.etc."element/config.json" = {
      text = builtins.toJSON (cfg.defaultSettings // cfg.config);
      mode = "0644";
    };

    # Auto-update configuration
    systemd.user.services.element-desktop-autoupdate = mkIf cfg.autoUpdate {
      description = "Element Desktop Auto-Update Service";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/element-desktop --check-update";
        Type = "oneshot";
      };
      wantedBy = [ "default.target" ];
      startAt = "daily";
    };

    # Desktop integration
    services.xserver.desktopManager.gnome3.extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      enable-hot-corners=false
    '';

    # Electron sandboxing
    security.chromiumSuidSandbox.enable = true;
  };
}
