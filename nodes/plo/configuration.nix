{
  # config,
  pkgs,
  requirements,
  ...
}: let
  # pkgs-unstable = requirements.inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  sudo-users-common = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "podman"
      "libvirtd"
      "audio"
      "video"
    ];
    packages = with pkgs; [
      home-manager
    ];
  };
in {
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  networking.hosts = {
    "127.0.0.1" = ["mysql"];
  };
  networking.domain = "local.host.pleme.io";

  imports = [
    requirements.inputs.self.nixosModules.blackmatter
    ./application_reverse_proxy
    ./supervisord
    ./dev_services
    ./containers
  ];

  blackmatter.profiles.blizzard.enable = true;

  users.users.luis =
    {
      uid = 1001;
      description = "luis";
    }
    // sudo-users-common;

  users.users.gab =
    {
      uid = 1002;
      description = "gab";
    }
    // sudo-users-common;

  users.users.gaby =
    {
      uid = 1003;
      description = "gaby";
    }
    // sudo-users-common;

  users.users.supervisor = {
    isSystemUser = true;
    uid = 1500;
    home = "/var/lib/supervisor";
    group = "supervisor";
    shell = pkgs.bash;
    description = "supervisor";
    createHome = true;
  };

  users.groups.supervisor = {
    gid = 1500; # Optional: Specify a GID
  };

  users.users.mysql = {
    isSystemUser = true;
    uid = 1600;
    home = "/var/lib/mysql";
    group = "mysql";
    shell = pkgs.bash;
    description = "mysql";
    createHome = true;
  };

  users.groups.mysql = {
    gid = 1600;
  };

  users.users.postgres = {
    isSystemUser = true;
    uid = 1700;
    home = "/var/lib/postgres";
    group = "postgres";
    shell = pkgs.bash;
    description = "postgres";
    createHome = true;
  };

  users.groups.postgres = {
    gid = 1700;
  };

  users.users.graphql = {
    isSystemUser = true;
    uid = 1800;
    home = "/var/lib/graphql";
    group = "graphql";
    shell = pkgs.bash;
    description = "graphql";
    createHome = true;
  };

  users.groups.graphql = {
    gid = 1800;
  };

  users.users.opensearch = {
    isSystemUser = true;
    uid = 2000;
    home = "/var/lib/opensearch";
    group = "opensearch";
    shell = pkgs.bash;
    description = "opensearch";
    createHome = true;
  };

  users.groups.opensearch = {
    gid = 2000;
  };

  users.users.nginx = {
    isSystemUser = true;
    uid = 2100;
    home = "/var/lib/nginx";
    group = "nginx";
    shell = pkgs.bash;
    description = "nginx";
    createHome = true;
  };

  users.groups.nginx = {
    gid = 2100;
  };

  security.sudo.extraConfig = ''
    luis ALL=(ALL) NOPASSWD:ALL
    gab ALL=(ALL) NOPASSWD:ALL
    gaby ALL=(ALL) NOPASSWD:ALL
  '';
  nixpkgs.config.allowImportFromDerivation = true;
}
