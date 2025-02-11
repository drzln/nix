{ requirements, pkgs, ... }: {
  home.packages = with pkgs; [
    # wl-clipboard-rs
    # wl-clipboard-x11
    wl-gammactl
    wl-gammarelay-rs
    wl-mirror
    wl-screenrec
    wl-color-picker
    wl-clip-persist
    wofi
    dunst
    waybar
    swaybg
    kitty
    alacritty
    foot
    wezterm
  ];

  # Enable and configure Hyprland
  wayland.windowManager.hyprland = {
    enable = false;
    package = requirements.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    settings = {
      monitor = "DP-2, 1920x1080@360, 0x0, 1";
      bind = [
        "SUPER_SHIFT, Q, exec, hyprctl dispatch exit"
        "SUPER, T, exec, foot"
        "SUPER_SHIFT, N, exec, notify-send \"Hyprland is working!\""
        "SUPER, SPACE, exec, wofi --show drun"
        "SUPER, Q, exec, hyprctl dispatch closewindow address:mouse"
      ];
      input = {
        force_no_accel = true;
        kb_layout = "pl";
        kb_variant = "";
        kb_model = "";
        kb_options = "caps:escape";
        kb_rules = "";

        follow_mouse = "1";

        touchpad = {
          natural_scroll = "yes";
        };
      };
    };
    plugins = [
      # requirements.inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      # requirements.inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprtrails
      # requirements.inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
      # requirements.inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprwinwrap
      # requirements.inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.borders-plus-plus
    ];
  };

  programs.wezterm.enable = true;
  programs.wezterm.extraConfig = builtins.readFile ./wezterm.lua;

  # Wofi configuration
  # home.file.".config/wofi/config" = {
  #   text = ''
  #     [colors]
  #     background = "#2E3440";
  #     foreground = "#D8DEE9";
  #     selection_background = "#4C566A";
  #     selection_foreground = "#D8DEE9";
  #   '';
  # };

  # Dunst configuration
  # home.file.".config/dunst/dunstrc" = {
  #   text = ''
  #     [global]
  #     background = "#2E3440";
  #     foreground = "#D8DEE9";
  #     frame_color = "#4C566A";
  #   '';
  # };
}
