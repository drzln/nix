###############################################################################
# shell packages
# packages that have nothing to do with a gui or desktop setup
###############################################################################
{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop.packages;
in
{
  options = {
    blackmatter = {
      components = {
        desktop.packages.enable = mkEnableOption "desktop.packages";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      #########################################################################
      # discord
      #########################################################################

      # overlay the discord-canary package
      # to install openasar https://openasar.dev/
      nixpkgs.overlays =
        let
          openasar = self: super: {
            discord-canary = super.discord.override { withOpenASAR = true; };
          };
        in
        [ openasar ];

      xdg.configFile."discordcanary/settings.json".text =
        "{\"SKIP_HOST_UPDATE\": true }";
      # end discord

      #########################################################################
      # ruby deps shell hook
      #########################################################################

      # makes it so rbenv install succeeds
      xdg.configFile."shellz/hooks/main.sh".text =
        "export CPATH=\"${pkgs.zlib.dev}/include:$CPATH\"" +
        "export LDFLAGS=\"-L${pkgs.zlib.out}/lib -L${pkgs.openssl.out}/lib\"" +
        "export CPPFLAGS=\"-I${pkgs.zlib.dev}/include -I${pkgs.openssl.dev}/include\""
      ;

      # end ruby deps shell hook

      home.packages = with pkgs;
        [
          #######################################################################
          # ruby deps
          # required for building rubies
          #######################################################################

          openssl
          zlib
          readline
          autoconf
          bash
          bashInteractive
          binutils
          coreutils
          diffutils
          findutils
          gdbm
          gnugrep
          gnused
          libffi
          libiconv
          libtool
          libyaml
          ncurses
          openssl.dev
          pkg-config
          which
          zlib.dev

          # end ruby deps

          gpauth
          gpclient

          gnome-tweaks
          # _1password-gui-beta
          # _1password
          fractal
          # blender
          spotify
          slack
          zoom-us
          kitty
          discord-canary
          webcamoid
          obsidian
          android-studio
          xdotool
          xtitle
          freecad
          libreoffice
          vscode
        ];
    })
  ];
}

# end shell packages
