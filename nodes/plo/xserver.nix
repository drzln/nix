{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    xkb = {
      options = "caps:escape";
      layout = "us";
      variant = "";
    };
    displayManager = {
      gdm = {
        enable = false;
        wayland = false;
      };
      lightdm = {
        enable = false;
      };
    };
    autoRepeatDelay = 135;
    autoRepeatInterval = 40;
    videoDrivers = [ "nvidia" ];
    desktopManager = {
      gnome = {
        enable = true;
      };
      xterm = {
        enable = false;
      };
    };
    windowManager = {
      leftwm = { enable = false; };
      i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3blocks
          i3status
          i3lock
          dmenu
        ];
      };
    };
  };
}
