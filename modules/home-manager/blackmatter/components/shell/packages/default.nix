{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  #############################################################################
  # docker compose custom build
  #############################################################################
  # linux only
  # docker-compose-alternative = pkgs.stdenv.mkDerivation rec {
  #   name = "docker-compose";
  #   version = "2.18.1";
  #   src = pkgs.fetchurl {
  #     url = "https://github.com/docker/compose/releases/download/v${version}/docker-compose-Linux-x86_64";
  #     sha256 = "sha256-tOav8Uww+CzibpTTdoa1WYs/hwzh4FOSfIU7T0sShXU=";
  #   };
  #
  #   phases = ["installPhase"];
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     cp $src $out/bin/docker-compose
  #     chmod +x $out/bin/docker-compose
  #   '';
  # };
  # end docker compose custom build
in {
  #############################################################################
  # options
  #############################################################################

  options = {
    blackmatter = {
      components = {
        shell.packages.enable =
          mkEnableOption "shell.packages";
      };
    };
  };

  # end options

  #############################################################################
  # config
  #############################################################################

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs;
        [
          ripgrep
        ]
        ++ lib.optionals isDarwin []
        ++ lib.optionals isLinux [
          # these are critical
          sops
          xsel
          nmap
          zoxide
          dig
          attic-client
          delta
          gnumake
          traceroute
          lazygit
          gh
          tree
          sumneko-lua-language-server
          bundix
          cargo
          awscli2
          arion
          llama-cpp
          # end these are critical

          # i3status
          # iproute2
          # s-tui
          # adbfs-rootless
          # docker-compose-alternative
          # usbutils
          # sheldon
          # julia
          # adb-sync
          # _1password-gui
          # beekeeper-studio
          # transmission_4
          # rust-analyzer
          # rustfmt
          # openssl
          # pkg-config
          # rustc
          # autorandr
          # dmenu
          # rxvt_unicode
          # android-tools
          # gnirehtet
          # jellyfin-ffmpeg
          # yq-go
          # unzip
          # opam
          # python3
          # mysql
          # tfsec
          # ruby
          # tfplugindocs
          # tfswitch
          # golint
          # duckdb
          # docker
          # delve
          # yarn
          # typescript
          # lazydocker
          # twitch-tui
          # wiki-tui
          # tuir
          # saml2aws
          # tuifeed
          # kompose
          # gcc
          # jdk
          # cargo
          # dotnet-sdk
          # podman-compose
          # tree
          # sshfs
          # php81Packages.composer
          # php81Packages.php-cs-fixer
          # xorriso
          # asmfmt
          # zlib
          # ssm-session-manager-plugin
          # cloud-nuke
          # nodejs
          # awscli2
          # goreleaser
          # go-task
          # gofumpt
          # gobang
          # go
          # terraform-ls
          # tflint
          # terraform-docs
          # terraform-landscape
          # terraform-compliance
          # kubectl
          # luarocks
          # lua
          # php
          # redis-dump
          # redis
          # redli
          # solargraph
          # rbenv
          # cargo-edit
          # rust-code-analysis
          # rust-analyzer
          # rust-script
          # rustic-rs
          # rust-motd
          # rusty-man
          # rustscan
          # rustfmt
          # rustcat
          # rustc
          # sops
          # gnupg
          # pinentry-curses
          # age
          # shfmt
          # tealdeer
          # himalaya
          # tree-sitter
          # yt-dlp
          # transmission_4
          # xorg.xrandr
          # tig
          # grex
          # gdb
          # bat
          # feh
          # fd
          # sd
          # hyperfine
          # bandwhich
          # json2hcl
          # node2nix
          # cpulimit
          # nushell
          # ansible
          # openssl
          # gradle
          # trunk
          # whois
          # delta
          # tokei
          # tree-sitter
          # httpie
          # procs
          # xclip
          # gpauth
          # gpclient
          # gp-saml-gui
          # openconnect
          # lazygit
          # gh
        ];
    })
  ];

  # end config
}
