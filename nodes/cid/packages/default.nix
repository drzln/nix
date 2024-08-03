{ config, pkgs, inputs, ... }: {
  environment.systemPackages =
    with pkgs;
    with inputs;
    [
      docker-client
      docker
      # terraform
      # comes up as undefined
      # pkgconfig
      nix-index
      pciutils
      tfswitch
      yarn2nix
      starship
      dnsmasq
      ansible
      ripgrep
      weechat
      gnumake
      openssh
      nixops
      # nodejs
      # TODO: poetry is flagged as insecure
      # poetry
      bundix
      cargo
      arion
      unzip
      gnupg
      lorri
      nomad
      vault
      ruby
      yarn
      xsel
      htop
      nmap
      stow
      zlib
      wget
      curl
      gcc
      age
      git
      fzf
      dig
      vim
      git
      # gh
    ];

}
