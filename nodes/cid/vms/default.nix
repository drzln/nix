{...}: {
  # nix = {
  #   settings.trusted-users = ["ldesiqueira"];
  #   settings.extra-trusted-users = ["ldesiqueira"];
  #   linux-builder = {
  #     enable = true;
  #     ephemeral = true;
  #     config = {pkgs, ...}: {
  #       system.stateVersion = "24.05";
  #       # environment.systemPackages = with pkgs; [vim];
  #       virtualisation = {
  #         darwin-builder = {
  #           diskSize = 40 * 1024;
  #           memorySize = 8 * 1024;
  #         };
  #         cores = 6;
  #       };
  #     };
  #   };
  # };
}
