{ pkgs, ... }: {
  home.packages = with pkgs; [
    # nixhashsync
    # autorandr
    # i3status
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
    # tree
    # yarn
    # typescript
    # lazydocker
    # # rnix-lsp
    # # nixopsUnstable
    # # postgres_with_libpq
    # lazygit
    # packer
    # twitch-tui
    # wiki-tui
    # tuir
    # dig
    # nmap
    # saml2aws
    # tuifeed
    # kompose
    # gcc
    # jdk
    # cargo
    # dotnet-sdk
    # ripgrep
    # podman-compose
    # tree
    # sshfs
    # php81Packages.composer
    # php81Packages.php-cs-fixer
    # xorriso
    # traceroute
    # iproute2
    # s-tui
    # usbutils
    # sheldon
    # julia
    # adb-sync
    # autoadb
    # python39Packages.pipenv-poetry-migrate
    # python39Packages.poetry-core
    # black
    # pipenv
    # poetry
    # asmfmt
    # zlib
    # ssm-session-manager-plugin
    # cloud-nuke
    # nodejs
    # nodePackages_latest.cdktf-cli
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
    # sumneko-lua-language-server
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
    # zoxide
    # httpie
    # procs
    # xclip
    # xsel
  ] ++ [
    # _1password-gui
    # google-chrome
    # beekeeper-studio
    # gpauth
    # gpclient
    # gp-saml-gui
    # openconnect
    # (pkgs.stdenv.mkDerivation {
    #   pname = "connect-vpn-pinger";
    #   version = "1.0.0";
    #
    #   src = pkgs.writeScript "connect-vpn-pinger.sh" ''
    #     #!/usr/bin/env bash
    #     sudo openconnect --protocol=gp --mtu=1200 pan.corp.pinger.com
    #   '';
    #
    #   phases = [ "installPhase" ];
    #
    #   installPhase = ''
    #     mkdir -p $out/bin
    #     install -m755 "$src" $out/bin/connect-vpn-pinger
    #   '';
    #
    # })
  ];
}
