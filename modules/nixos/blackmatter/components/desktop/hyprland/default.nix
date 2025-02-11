{ lib, pkgs, config, ... }:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  cfg = config.blackmatter.components.desktop.hyprland;
in
{
  options = {
    blackmatter = {
      components = {
        desktop.hyprland.enable = mkEnableOption "hyprland";
        # desktop.hyprland.monitors = mkOption {
        #   type = types.attrs;
        #   description = "monitor related attributes";
        # };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Enable Wayland hardware acceleration (OpenGL)
      hardware.opengl.enable = true;

      # Enable seatd for seat/session management, required by Hyprland
      services.seatd.enable = true;

      # Input device configuration via libinput (Wayland-friendly)
      services.libinput.enable = true;

      # Choose video drivers if necessary (adjust for your hardware)
      services.xserver.videoDrivers = [ "nvidia" ];

      # minimal greetd
      services.greetd = {
        enable = true;
        greeter = {
          package = pkgs.agreety;
        };
        defaultSession = "hyprland";
        sessions = [
          {
            name = "hyprland";
            command = "${pkgs.hyprland}/bin/Hyprland";
          }
        ];
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    })
  ];
}
