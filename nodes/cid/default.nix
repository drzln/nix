# nodes/cid/default.nix
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./vms
  ];
  system.stateVersion = 4;
  ids.gids.nixbld = 350;
  networking.hostName = "cid";
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
  documentation.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;
  documentation.man.enable = false;
  programs.zsh.enable = true;
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
  system.defaults = {
    NSGlobalDomain.KeyRepeat = 2; # how fast keys repeat
    NSGlobalDomain.InitialKeyRepeat = 20; # delay before repeating starts
  };
  services.yabai = {
    enable = false;
    enableScriptingAddition = true;
    package = pkgs.yabai;
    config = {
      enable = true;
      sticky = "on";
      mouse_follows_focus = "off";
      focus_follows_mouse = "autoraise";
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = 0.0;
      layout = "bsp";
      window_gap = 10;
      window_border = "on";
      window_border_width = 2;
    };
  };
  services.skhd = {
    enable = false;
    package = pkgs.skhd;
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
  environment.systemPackages = with pkgs; [
    gh
    slack-cli
    cargo
    sumneko-lua-language-server
    docker
    docker-client
    tfswitch
    ripgrep
    weechat
    gnumake
    openssh
    nix-index
    nodejs
    bundix
    zoxide
    arion
    unzip
    gnupg
    lorri
    htop
    wget
    nmap
    stow
    zlib
    wget
    curl
    gcc
    age
    git
    dig
    vim
  ];
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
      LIBRARY_PATH = "${pkgs.libiconv}/lib";
      C_INCLUDE_PATH = "${pkgs.libiconv}/include";
    };
    programs.home-manager.enable = true;
    blackmatter.profiles.frost.enable = true;
    manual.manpages.enable = false;
    home.file.".hammerspoon/init.lua".source = ./hammerspoon-init.lua;
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
}
