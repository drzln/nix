{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./vms
  ];

  ############################################
  # System & Host
  ############################################

  # Adjust this to the latest you can, but keep it in sync with your actual system stateVersion constraints.
  system.stateVersion = 4;
  ids.gids.nixbld = 350;

  # Machine name
  networking.hostName = "cid";

  ############################################
  # Nix / Nix-Darwin Settings
  ############################################

  # Allow unfree packages selectively, etc.
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "packer"
      ];
    permittedInsecurePackages = [
      "python2.7-pyjwt-1.7.1"
    ];
  };

  nix.settings.sandbox = false;
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # services.nix-daemon.enable = true;

  # Keep documentation off (man/info etc.) to save space
  documentation.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;
  documentation.man.enable = false;

  ############################################
  # Shell / Keyboard
  ############################################

  # Enable ZSH from the system side (note you can also manage ZSH in Home Manager).
  programs.zsh.enable = true;

  # Basic keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    # Optionally set more remaps here:
    # remapRightOptionToRightControl = true;
  };

  # Tweak macOS keyboard repeat speeds
  # Lower values = faster repeat
  system.defaults = {
    NSGlobalDomain.KeyRepeat = 2; # how fast keys repeat
    NSGlobalDomain.InitialKeyRepeat = 20; # delay before repeating starts
  };

  ############################################
  # Window Management: Yabai + skhd
  ############################################

  # We rely on the Nix-Darwin service for yabai
  services.yabai = {
    enable = false;

    # If you want the scripting addition features (borders, spaces, etc.),
    # you must disable or partially disable SIP, then sign the scripting addition.
    enableScriptingAddition = true;

    # If you want to override the actual derivation used:
    package = pkgs.yabai;

    # Minimal config inline; you can also specify `configFile` or do advanced options:
    config = {
      enable = true; # have Nix-Darwin generate a config
      sticky = "on";
      mouse_follows_focus = "off";
      focus_follows_mouse = "autoraise";
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = 0.0;
      # Add some typical tiling defaults:
      layout = "bsp";
      window_gap = 10;
      window_border = "on";
      window_border_width = 2;
      # If you prefer using hex colors for borders, you could set:
      # active_window_border_color = "0xffa1b56c";
      # normal_window_border_color = "0xff7cafc2";
    };
  };

  # Keyboard shortcuts for yabai, using skhd
  services.skhd = {
    enable = false;
    package = pkgs.skhd;
    # Add an environment variable to point skhd to a custom log file:
    # serviceConfig = {
    #   Environment = [
    #     "SKHD_LOG_FILE=/var/skhd/skhd.log"
    #   ];
    # };

    # Inline config. Often you might prefer a separate `skhdrc` file
    # for cleanliness, but inline is fully supported too.
    skhdConfig = ''
      cmd + j : echo 'wut'
      # ──────────────────────────────────────────────────────────
      # Basic Vim-like window focus
      # ──────────────────────────────────────────────────────────
      # alt - h : yabai -m window --focus west
      # alt - j : yabai -m window --focus south
      # alt - k : yabai -m window --focus north
      # alt - l : yabai -m window --focus east

      # ──────────────────────────────────────────────────────────
      # Swap windows
      # ──────────────────────────────────────────────────────────
      # shift + alt - h : yabai -m window --swap west
      # shift + alt - j : yabai -m window --swap south
      # shift + alt - k : yabai -m window --swap north
      # shift + alt - l : yabai -m window --swap east

      # ──────────────────────────────────────────────────────────
      # Resize windows (example keys using ctrl+alt)
      # Adjust step size as you prefer.
      # ──────────────────────────────────────────────────────────
      # ctrl + alt - h : yabai -m window --resize left:-20
      # ctrl + alt - j : yabai -m window --resize bottom:20
      # ctrl + alt - k : yabai -m window --resize top:-20
      # ctrl + alt - l : yabai -m window --resize right:20

      # ──────────────────────────────────────────────────────────
      # Toggling states
      # ──────────────────────────────────────────────────────────
      # alt - f : yabai -m window --toggle zoom-fullscreen
      # alt - t : yabai -m window --toggle float

      # Move to next display
      alt - n : yabai -m window --display next; yabai -m display --focus next

      # Reload services if needed
      # (Assumes brew. If you manage them purely from nix-darwin, you can do a killall + launchctl approach)
      # alt + shift - r : brew services restart yabai; brew services restart skhd
    '';
  };

  ############################################
  # System Packages
  ############################################

  environment.systemPackages = with pkgs; [
    gh
    slack-cli
    # sumneko-lua-language-server
    # docker
    # docker-client
    # tfswitch
    # yarn2nix
    # starship
    # dnsmasq
    # ansible
    # ripgrep
    # weechat
    # gnumake
    # openssh
    # nix-index
    # nodejs
    # bundix
    # zoxide
    # cargo
    # arion
    # unzip
    # gnupg
    # lorri
    # ruby
    # yarn
    # xsel
    # htop
    # nmap
    # stow
    # zlib
    # wget
    # curl
    # gcc
    # age
    # git
    # dig
    # vim
    # gh
  ];

  ############################################
  # Users
  ############################################

  # Example local user
  users.users.ldesiqueira = {
    # Make sure this matches the actual UID on your system if not using the default 501
    uid = 1002;
    home = "/Users/ldesiqueira";

    # Packages installed specifically for this user in /run/current-system/sw (global-ish).
    # Typically, you'd prefer to manage user-specific packages in Home Manager, but it's fine.
    packages = with pkgs; [
      # ruby # NB: This duplicates the system package. Consider removing from one place.
      # php83Packages.composer
      darwin.apple_sdk.frameworks.CoreServices
      nerd-fonts.fira-code
      dotnet-sdk_8
      home-manager
      nixhashsync
      libiconv
      poetry
      clang
      delta
      bat
      go
    ];
  };

  users.users.drzzln = {
    # Make sure this matches the actual UID on your system if not using the default 501
    uid = 1003;
    home = "/Users/drzzln";

    # Packages installed specifically for this user in /run/current-system/sw (global-ish).
    # Typically, you'd prefer to manage user-specific packages in Home Manager, but it's fine.
    packages = with pkgs; [
      # ruby # NB: This duplicates the system package. Consider removing from one place.
      # php83Packages.composer
      darwin.apple_sdk.frameworks.CoreServices
      nerd-fonts.fira-code
      dotnet-sdk_8
      home-manager
      nixhashsync
      libiconv
      poetry
      clang
      delta
      bat
      go
    ];
  };

  home-manager.useGlobalPkgs = false;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {inherit pkgs;};
  nixpkgs.overlays = import ../../overlays;

  home-manager.users.drzzln = {...}: {
    imports = [../../modules/home-manager/blackmatter];
    home.stateVersion = "23.11";
    home.sessionVariables = {
      KUBE_EDITOR = "nvim";
    };

    programs.home-manager.enable = true;
    blackmatter.profiles.frost.enable = true;
    manual.manpages.enable = false;
    home.file.".gitconfig".text = ''
      [user]
        email = drzzln@protonmail.com
        name = drzzln

      [merge]
        default = merge

      [core]
        pager = delta --dark --line-numbers
        editor = vim

      [delta]
        side-by-side = true
    '';
  };

  home-manager.users.ldesiqueira = {...}: {
    imports = [../../modules/home-manager/blackmatter];
    home.stateVersion = "23.11";
    home.sessionVariables = {
      KUBE_EDITOR = "nvim";
    };

    programs.home-manager.enable = true;
    blackmatter.profiles.frost.enable = true;
    manual.manpages.enable = false;
    home.file.".gitconfig".text = ''
      [user]
        email = ldesiqueira@pinger.com
        name = luis

      [merge]
        default = merge

      [core]
        pager = delta --dark --line-numbers
        editor = vim

      [delta]
        side-by-side = true
    '';
  };
}
