# modules/nixos/blackmatter/profiles/default.nix
{
  # lib,
  # config,
  ...
}: let
  # cfg = config.blackmatter.profiles;
in {
  imports = [
    ./blizzard
  ];
}
