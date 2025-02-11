{ lib, pkgs, config, ... }:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  cfg = config.blackmatter.components.desktop.hyprland;

  nord.graphics.indicator = ">";
  nord.graphics.border.child = "1";
  nord.colors = rec {
    i3lock.background.blue = "#2E3440";
    primary = "#5E81AC";
    secondary = "#D8DEE9";
    tertiary = "#88C0D0";
    highlight = "#BF616A";
    foreground = "#ECEFF4";
    background.blue = "#2E3440";
    background.teal = "#8fbcbb";
    text.white = "#d8dee9";
    error.red = highlight;
    error.background.grey = "#4c566a";
  };

  themes.nord = rec {
    rofi = "Arc-Dark";
    globals = {
      colors.focused = {
        border = nord.colors.background.blue;
        background = nord.colors.background.blue;
        text = nord.colors.text.white;
        indicator = nord.graphics.indicator;
        childBorder = nord.graphics.border.child;
      };
      colors.focusedInactive = {
        border = nord.colors.background.blue;
        background = nord.colors.background.blue;
        text = nord.colors.text.white;
        indicator = nord.graphics.indicator;
        childBorder = nord.graphics.border.child;
      };
      colors.unfocused = {
        border = nord.colors.background.blue;
        background = nord.colors.background.blue;
        text = nord.colors.text.white;
        indicator = nord.graphics.indicator;
        childBorder = nord.graphics.border.child;
      };
      colors.urgent = {
        border = nord.colors.error.red;
        background = nord.colors.error.background.grey;
        text = nord.colors.text.white;
        indicator = nord.graphics.indicator;
        childBorder = nord.graphics.border.child;
      };
      colors.hovered = {
        border = nord.colors.background.teal;
        background = nord.colors.background.blue;
        text = nord.colors.text.white;
        indicator = nord.graphics.indicator;
        childBorder = nord.graphics.border.child;
      };
    };
    initialization = {
      # manipulate the path or we do not find pamixer
      script = "PATH=$HOME/.nix-profile/bin:$PATH polybar top &";
    };
    styling = {
      font-0 = "RobotoMono Nerd Font:antialias=true:hinting=true;size=10;2";
      padding = 2;
    };
    dimensions = {
      height = 30;
      width = "100%";
    };
    elements = {
      separator = "|";
    };
    colors = {
      background = nord.colors.background.blue;
      foreground = nord.colors.foreground;
    };
  };


in
{
  options = {
    blackmatter = {
      components = {
        desktop.hyprland.enable = mkEnableOption "hyprland";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {

      programs.obs-studio.enable = true;
      home.packages = with pkgs; [
        ghostty
        xdg-desktop-portal-hyprland
        xdg-desktop-portal
        hyprpicker
        hyprland
        anyrun
        walker
        dunst
        mako
        grim
        slurp
        fnott
        wofi
        waybar
        hyprpaper
        hypridle
        hyprlock
        hyprcursor
        hyprutils
        hyprlang
        hyprwayland-scanner
        aquamarine
        nordzy-icon-theme
        nordzy-cursor-theme
        dissent
        vesktop
        webcord
        clipman
        cliphist
        wl-clip-persist
        clipse
        yazi
        nnn
        ranger
        superfile
        spacedrive
        udiskie
        waydroid
        zathura
        waypipe
        xdotool
      ];

      home.file.".local/share/icons/Nordzy-cursors" = {
        source = "${pkgs.nordzy-cursor-theme}/share/icons/Nordzy-cursors";
      };

      home.file.".icons/Nordzy-cursors" = {
        source = "${pkgs.nordzy-cursor-theme}/share/icons/Nordzy-cursors";
      };

      home.sessionVariables = {
        OZONE_PLATFORM = "wayland";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        HYPRCURSOR_THEME = "Nordzy-cursors";
        HYPRCURSOR_SIZE = "24";
        XCURSOR_THEME = "Nordzy-cursors";
        XCURSOR_SIZE = "24";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_CURRENT_DESKTOP = "Hyprland";
        QT_QPA_PLATFORM = "wayland";
        GDK_BACKEND = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      # hyprland
      home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
      home.file.".config/hypr/env.conf".source = ./env.conf;
      home.file.".config/hypr/input.conf".source = ./input.conf;
      home.file.".config/hypr/monitors.conf".source = ./monitors.conf;
      home.file.".config/hypr/variables.conf".source = ./variables.conf;
      home.file.".config/hypr/bindings.conf".source = ./bindings.conf;
      home.file.".config/hypr/autostart.conf".source = ./autostart.conf;
      home.file.".config/hypr/cursor.conf".source = ./cursor.conf;

      #waybar
      home.file.".config/waybar/config".source = ./waybar-config.json;
      home.file.".config/waybar/style.css".source = ./waybar-style.css;

      # hyprpaper
      home.file.".config/hypr/wallpaper.jpg".source = ./wallpaper.jpg;
      home.file.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;

      # hypridle
      home.file.".config/hypr/hypridle.conf".source = ./hypridle.conf;

      #hyprlock
      home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;

      #xdph
      home.file.".config/hypr/xdph.conf".source = ./xdph.conf;


      # notifications
      services.dunst = {
        enable = true;
        settings = {
          global = {
            font = "RobotoMono Nerd Font 10";
            frame_color = nord.colors.background.blue;
            background = nord.colors.background.blue;
            foreground = nord.colors.foreground;

            # how long the alert lasts
            timeout = 3;

            # positioning of alert window
            # does not seem to be working
            #geometry = "300x5-10-50"; # Width x Stack Size - X Offset - Y Offset

          };
          urgency_low = {
            background = nord.colors.secondary;
            foreground = nord.colors.background.blue;
          };
          urgency_normal = {
            background = nord.colors.background.blue;
            foreground = nord.colors.foreground;
          };
          urgency_critical = {
            background = nord.colors.error.background.grey;
            foreground = nord.colors.error.red;
          };
        };
      };
    })
  ];
}
