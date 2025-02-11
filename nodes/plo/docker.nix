{lib, ...}: {
  systemd.services.docker.serviceConfig = {
    LimitNOFILE = "1048576";
    LimitNPROC = "65536";
    LimitSTACK = "infinity";
    LimitMEMLOCK = "infinity";
  };

  systemd.user.services.docker.serviceConfig = {
    # competes with virtualisation values
    # LimitNOFILE = 1048576;
    # LimitNPROC = 65536;
    LimitSTACK = "infinity";
    LimitMEMLOCK = "infinity";
  };

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
    DefaultLimitNPROC=65536
    DefaultLimitSTACK=infinity
    DefaultLimitMEMLOCK=infinity
  '';

  environment.etc."docker/daemon.json".text = ''
    {
      "default-ulimits": {
        "nofile": {
          "Name": "nofile",
          "Soft": 1048576,
          "Hard": 1048576
        },
        "nproc": {
          "Name": "nproc",
          "Soft": 65536,
          "Hard": 65536
        }
      }
    }'';
}
