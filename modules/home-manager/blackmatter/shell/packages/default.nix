{ lib, pkgs, config, stdenv, ... }:
with lib;
let
  cfg = config.blackmatter;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  #############################################################################
  # postgres
  #############################################################################

  postgres_with_libpq = pkgs.postgresql_15.overrideAttrs (oldAttrs: {
    enableSystemd = false;
  });

  # end postgres

  #############################################################################
  # docker compose custom build
  #############################################################################

  # linux only
  docker-compose-alternative = stdenv.mkDerivation rec {
    name = "docker-compose";
    version = "2.18.1";
    src = pkgs.fetchurl {
      url = "https://github.com/docker/compose/releases/download/v${version}/docker-compose-Linux-x86_64";
      sha256 = "sha256-tOav8Uww+CzibpTTdoa1WYs/hwzh4FOSfIU7T0sShXU=";
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/docker-compose
      chmod +x $out/bin/docker-compose
    '';
  };

  # end docker compose custom build
in
{
  #############################################################################
  # options
  #############################################################################

  options = {
    blackmatter = {
      shell.packages.enable =
        mkEnableOption "shell.packages";
    };
  };

  # end options

  #############################################################################
  # config
  #############################################################################

  config = mkMerge [
    (mkIf cfg.shell.packages.enable {

      home.packages = with pkgs;
        [
          git-remote-gcrypt
          android-tools
          coreutils-prefixed
          gnirehtet
          jellyfin-ffmpeg
          yq-go
          unzip
          opam
          # yq
          # python3
          mysql
          tfsec
          ruby
          tfplugindocs
          tfswitch
          golint
          duckdb
          docker
          delve
          tree
          yarn
          typescript
          lazydocker
          nixopsUnstable
          postgres_with_libpq
          lazygit
          packer
          twitch-tui
          wiki-tui
          tuir
          dig
          nmap
          spotify-tui
          saml2aws
          tuifeed
          kompose
          gcc
          jdk
          cargo
          dotnet-sdk
          ripgrep
          podman-compose
          tree
          sshfs
          php81Packages.composer
          php81Packages.php-cs-fixer
          xorriso
        ]
        ++ import ./python pkgs
        ++ import ./kubernetes pkgs
        ++ import ./javascript pkgs
        ++ import ./hashicorp pkgs
        ++ import ./utilities pkgs
        ++ import ./rustlang pkgs
        ++ import ./secrets pkgs
        ++ import ./arduino pkgs
        ++ import ./golang pkgs
        ++ import ./redis pkgs
        ++ import ./ruby pkgs
        ++ import ./shell pkgs
        ++ import ./aws pkgs
        ++ import ./nix pkgs
        ++ import ./asm pkgs
        ++ import ./lua pkgs
        ++ import ./php pkgs
        ++ lib.optionals isDarwin [
          xhyve
          # (zulu.overrideAttrs (_:
          #   {
          #     # hack the jdk package because of a dumb bug on macos
          #     # https://github.com/LnL7/nix-darwin/issues/320
          #     postPatch = ''
          #       rm -rf share/man
          #       rm -rf man
          #       mkdir -p share
          #       ln -s ../zulu-11.jdk/Contents/Home/man/ share
          #
          #     '';
          #   }
          # ))
        ]
        ++ lib.optionals isLinux [
          # adbfs-rootless
          docker-compose-alternative
          traceroute
          iproute2
          s-tui
          usbutils
          sheldon
          julia
          adb-sync
          autoadb
        ];
    })
  ];

  # end config
}
