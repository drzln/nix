{...}: {
  nix = {
    settings.trusted-users = ["ldesiqueira"];
    linux-builder = {
      enable = true;
      ephemeral = true;
      # config = {pkgs, ...}: {
      #   environment.systemPackages = with pkgs; [neovim];
      # };
      # config = {
      #   virtualisation.darwin-builder.user = "ldesiqueira";
      #   virtualisation.darwin-builder.hostPort = 22;
      # };
    };
  };
}
