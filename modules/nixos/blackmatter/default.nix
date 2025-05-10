# modules/nixos/blackmatter/default.nix
{
  # lib,
  # config,
  ...
}: let
  # cfg = config.blackmatter;
in {
  imports = [
    ./profiles
    # ./components
  ];

  # options = {
  #   blackmatter = {
  #     enable = mkEnableOption "enable blackmatter";
  #   };
  # };
}
