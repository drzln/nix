# modules/nixos/blackmatter/profiles/blizzard/default.nix
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.profiles.blizzard;
in {
  imports = [
    ./displayManager
    # ./virtualisation
    ./networking
    ./bluetooth
    ./xserver
    ./locale
    ./limits
    ./docker
    ./sound
    ./boot
    ./time
    ./nix
  ];

  options = {
    blackmatter = {
      profiles = {
        blizzard = {
          enable = mkEnableOption "enable the blizzard profile";
        };
      };
    };
  };

  config =
    mkMerge [
      (mkIf (cfg.enable)
        {
          console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
          };
          powerManagement.cpuFreqGovernor = "performance";
          environment.variables = {
            GBM_BACKEND = "nvidia-drm";
          };
          services.dbus.enable = true;
          services.udev.enable = true;
          services.printing.enable = false;
          services.hardware.bolt.enable = false;
          services.nfs.server.enable = false;
          security.rtkit.enable = true;
          services.seatd.enable = true;
          programs.zsh.enable = true;
          services.libinput = {enable = true;};
          xdg.portal.enable = true;
          xdg.portal.wlr.enable = true;
          hardware.nvidia.open = false;
          hardware.graphics = {
            enable = true;
          };
          environment.systemPackages = with pkgs; [
            greetd.greetd
            greetd.regreet
            greetd.tuigreet
            # requirements.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
            # xdg-desktop-portal-wlr
            # xdg-desktop-portal-gtk
            vim
            wget
            git
            bash
            fontconfig
          ];
          fonts.fontconfig.enable = true;
          fonts.fontDir.enable = true;
          fonts.enableDefaultPackages = true;
          fonts.packages = with pkgs; [
            fira-code
            fira-code-symbols
            dejavu_fonts
          ];
          programs.hyprland.enable = true;
          # programs.hyprland.xwayland.enable = false;
          # programs.hyprland.package = requirements.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          # programs.hyprland.portalPackage = requirements.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          programs.regreet.enable = true;
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "
${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland
";
              };
            };
          };
        })
    ];
}
