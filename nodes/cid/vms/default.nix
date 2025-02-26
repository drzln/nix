{...}: {
  nix = {
    settings.trusted-users = ["ldesiqueira"];
    linux-builder = {
      enable = true;
      ephemeral = true;
      # config = {
      #   virtualisation.darwin-builder.user = "ldesiqueira";
      #   virtualisation.darwin-builder.hostPort = 22;
      # };
    };
  };
}
