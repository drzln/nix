{ lib, pkgs, config, ... }:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  cfg = config.blackmatter.components.desktop.i3;
  monitors = cfg.monitors;

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
        desktop.i3.enable = mkEnableOption "i3";
        desktop.i3.monitors = mkOption {
          type = types.attrs;
          description = "monitor related attributes";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      xsession.enable = true;
      xsession = {
        windowManager = {
          i3 = {
            enable = true;
            package = pkgs.i3-gaps;
            config = {
              modes = { };
              keybindings = { };
              # modifier = "Mod4";
              floating.modifier = "Mod4"; # Set floating_modifier to Mod4
              window.border = 0;
              fonts = {
                names = [ themes.nord.styling.font-0 ];
                size = 10.0;
              };
              # send alt+d to menu
              menu = "rofi -show drun";
              # alacritty has zoom in and out
              terminal = "kitty";
              # if you have polybar active remove default bars configuration
              bars = [ ];
              colors.urgent = themes.nord.globals.colors.urgent;
              colors.focused = themes.nord.globals.colors.focused;
              colors.unfocused = themes.nord.globals.colors.unfocused;
              colors.focusedInactive = themes.nord.globals.colors.focusedInactive;
            };
            extraConfig = ''
                     # Set the Mod key to the Super/Windows key
                     set $mod Mod1

                     ################################################################################
                     # bindings
                     ################################################################################

                     ########################################
                     # workspace
                     ########################################

                     bindsym $mod+0 workspace number 10
                     bindsym $mod+1 workspace number 1
                     bindsym $mod+2 workspace number 2
                     bindsym $mod+3 workspace number 3
                     bindsym $mod+4 workspace number 4
                     bindsym $mod+5 workspace number 5
                     bindsym $mod+6 workspace number 6
                     bindsym $mod+7 workspace number 7
                     bindsym $mod+8 workspace number 8
                     bindsym $mod+9 workspace number 9
                     bindsym $mod+Shift+0 move container to workspace number 10
                     bindsym $mod+Shift+1 move container to workspace number 1
                     bindsym $mod+Shift+2 move container to workspace number 2
                     bindsym $mod+Shift+3 move container to workspace number 3
                     bindsym $mod+Shift+4 move container to workspace number 4
                     bindsym $mod+Shift+5 move container to workspace number 5
                     bindsym $mod+Shift+6 move container to workspace number 6
                     bindsym $mod+Shift+7 move container to workspace number 7
                     bindsym $mod+Shift+8 move container to workspace number 8
                     bindsym $mod+Shift+9 move container to workspace number 9

                     ########################################
                     # end workspace
                     ########################################

                     ########################################
                     # focus
                     ########################################

                     # bindsym $mod+Down focus down
                     # bindsym $mod+Left focus left
                     # bindsym $mod+Right focus right
                     # bindsym $mod+Up focus up
                     # bindsym $mod+space focus mode_toggle
                     # bindsym $mod+a focus parent

                     ########################################
                     # end focus
                     ########################################

                     ########################################
                     # moves
                     ########################################

                     # bindsym $mod+Shift+Down move down
                     # bindsym $mod+Shift+Left move left
                     # bindsym $mod+Shift+Right move right
                     # bindsym $mod+Shift+Up move up
                     # bindsym $mod+Shift+space floating toggle

                     ########################################
                     # end moves
                     ########################################

                     ########################################
                     # tabs
                     ########################################

                     # bindsym $mod+w layout tabbed
                     # bindsym $mod+s layout stacking
                     # bindsym $mod+e layout toggle split
                     # bindsym $mod+h split h
                     # bindsym $mod+v split v
                     # bindsym $mod+r mode resize

                     ########################################
                     # end tabs
                     ########################################

                     bindsym $mod+Return exec kitty
                     bindsym $mod+d exec rofi -show drun
                     bindsym $mod+Shift+c reload
                     bindsym $mod+Shift+r restart
                     bindsym $mod+Shift+q kill
                     bindsym $mod+Shift+e exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'
                     # bindsym $mod+f fullscreen toggle
                     # bindsym $mod+minus scratchpad show

                     ################################################################################
                     # end bindings
                     ################################################################################

                     # remove borders
                     for_window [class="^.*"] border pixel 0
                     for_window [class="^.*"] gaps inner all

                     gaps inner 0
                     gaps outer 0

                     # make the background nord color
                     exec_always --no-startup-id xsetroot -solid "${nord.colors.background.blue}"

                     # screen locking
                     # TODO: for now set directly but move to config file in the future
                     bindsym $mod+Shift+l exec i3lock -c "${nord.colors.i3lock.background.blue}" -u

                     # Volume control (requires appropriate packages)
                     bindsym XF86AudioRaiseVolume exec amixer set Master 5%+
                     bindsym XF86AudioLowerVolume exec amixer set Master 5%-
                     bindsym XF86AudioMute exec amixer set Master toggle

                     #################################
                     # monitor
                     #################################

              	      exec --no-startup-id \
              	      	${pkgs.xorg.xrandr}/bin/xrandr \
              	      	--output ${monitors.main.name} \
              	      	--mode ${monitors.main.mode} \
              	      	--rate ${monitors.main.rate}


                     #################################
                     # end monitor
                     #################################
            '';
          };
        };
      };

      xdg.configFile."i3lock/config".text = ''
        background_color = "${nord.colors.i3lock.background.blue}"
      '';

      # audio requirements and polybar assistance
      home.packages = with pkgs; [
      ] ++ lib.optional stdenv.isLinux [
        alsa-utils
        pamixer # Volume control tool compatible with PipeWire
        qpwgraph # graphical audio mapping
        polybar
        libcamera
        pipewire # PipeWire audio server
        wireplumber # Session manager for PipeWire
      ];
      services.polybar = with themes.nord;
        {
          enable = true;
          config = {
            "module/date" = {
              internal = 5;
              label = "%date% %time%";
              type = "internal/date";
              date = "%Y-%m-%d";
              time = "%H:%M %Z";
            };
            "module/volume" = {
              type = "custom/script";
              exec = "pamixer --get-volume-human";
              interval = "1";
              click-left = "pamixer --increase 5";
              click-right = "pamixer --decrease 5";
              click-middle = "pamixer --toggle-mute";
              label = " %output%";
              label-muted = " Muted";
              format-muted = "<label-muted>";
            };
            "bar/top" = {
              monitor = monitors.main.name;
              modules-right = "date volume";
            } // colors // elements // styling // dimensions;
          };
        } // initialization;

      # enable the rofi launcher
      programs.rofi.enable = true;
      programs.rofi.theme = themes.nord.rofi;



      # enable dunst notifications
      services.dunst.enable = true;
      services.dunst.settings = {
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

      # set backgrounds in place
      home.file."backgrounds/nord/tools".source = builtins.fetchGit
        {
          url = "https://github.com/arcticicestudio/nord.git";
          ref = "develop";
          rev = "c93f12b23baac69a92e7559f69e7a60c20b9da0d";
        };

      home.file."backgrounds/nord/backgrounds".source = builtins.fetchGit
        {
          url = "https://github.com/dxnst/nord-backgrounds.git";
          ref = "main";
          rev = "c47d6b8b0ea391fabbb79aa005703ae5549ffdc4";
        };
    })
  ];
}
