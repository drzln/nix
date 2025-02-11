{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.profiles;
in
{
  imports = [
    ./blizzard
  ];
}
