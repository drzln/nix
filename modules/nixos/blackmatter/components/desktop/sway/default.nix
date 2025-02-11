{ pkgs, ... }: {
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.wrapperFeatures.gtk = true;
  wayland.windowManager.sway.systemdIntegration = true;
  wayland.windowManager.sway.config.terminal = "alacritty";
  wayland.windowManager.sway.config.left = "h";
  wayland.windowManager.sway.config.down = "j";
  wayland.windowManager.sway.config.up = "k";
  wayland.windowManager.sway.config.right = "l";
  wayland.windowManager.sway.config.menu = ''
    ${pkgs.wofi}/bin/wofi --show=drun| ${pkgs.xe}/bin/xe swaymsg exec
  '';
  # Mod1 is Alt
  wayland.windowManager.sway.config.modifier = "Mod1";
  wayland.windowManager.sway.config.output = {
    "eDP-1".background = "~/backgrounds/nord/backgrounds/operating-systems/1920x1080/nixos.png stretch";
  };
  wayland.windowManager.sway.config.bars = [
    {
      mode = "dock";
      hiddenState = "hide";
      position = "bottom";
      workspaceButtons = false;
      workspaceNumbers = false;
      statusCommand = "${pkgs.i3status}/bin/i3status";
      fonts = {
        names = [ "firacode" ];
        size = 11.0;
      };
      trayOutput = "primary";
      colors = {
        background = "#2e3440";
        statusline = "#d8dee9";
        separator = "#666666";
        focusedWorkspace = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
        };
        activeWorkspace = {
          border = "#333333";
          background = "#5f676a";
          text = "#ffffff";
        };
        inactiveWorkspace = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
        };
        urgentWorkspace = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
        };
        bindingMode = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
        };
      };
    }
  ];
  wayland.windowManager.sway.extraConfig = ''
    # basic us keyboard with caps as escape
    input * {
      xkb_layout "us"
      xkb_variant "basic"
      xkb_options "caps:escape"
    }

    # you tuned this they are not defaults
    input * repeat_delay 150
    input * repeat_rate 88

    # Brightness
    bindsym XF86MonBrightnessDown exec light -U 10
    bindsym XF86MonBrightnessUp exec light -A 10

    # Volume
    bindsym XF86AudioRaiseVolume exec 'pamixer -i 5'
    bindsym XF86AudioLowerVolume exec 'pamixer -d 5'
    bindsym XF86AudioMute exec 'pamixer -d 100'

    # screen locking
    set $lock swaylock -c 550000
    exec swayidle -w \
      timeout 120 $lock \
      timeout 240 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"' \
      before-sleep $lock
    
    set $lockman exec bash ~/.config/sway/lockman.sh
    bindsym Mod1+0 exec $lockman
  '';
  xdg.configFile."sway/lockman.sh".source = ./lockman.sh;
  programs.waybar.enable = false;
}
