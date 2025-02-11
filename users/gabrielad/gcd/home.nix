{ pkgs, ... }:
{
  imports = [
    ./programs.nix
    ./packages.nix
    ./background.nix
    ./blackmatter.nix
  ];

  home.stateVersion = "24.05";
  home.username = "gabrielad";
  home.homeDirectory = "/home/gabrielad";

  # Enable XSession with GNOME as the window manager
  xsession.enable = true;

  # xsession.windowManager.gnome.enable = true;

  # Customize GNOME settings, including themes, icons, and keybindings
  # services.gnome.gsettings = {
  #   enable = true;
  #
  #   overrides = {
  #     "/org/gnome/desktop/interface" = {
  #       "gtk-theme" = "Adwaita-dark";
  #       "icon-theme" = "Papirus-Dark";
  #       "cursor-theme" = "Adwaita";
  #     };
  #
  #     "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
  #       "binding" = "<Super>d";
  #       "command" = "dmenu_run";
  #       "name" = "Program Launcher (dmenu)";
  #     };
  #   };
  # };

  # GPG configuration for secure encryption and signing
  programs.gpg.enable = true;

  services.gpg-agent.enable = true;

  services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;

  services.gpg-agent.extraConfig = ''
    default-cache-ttl 600
    max-cache-ttl 7200
  '';
}

