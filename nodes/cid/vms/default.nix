{...}: {
  nix = {
    settings.trusted-users = ["ldesiqueira"];
    linux-builder = {
      enable = true;
      ephemeral = true;
      config = {pkgs, ...}: {
        system.stateVersion = "24.05";
        # environment.systemPackages = with pkgs; [neovim];
      };
    };
  };
}
