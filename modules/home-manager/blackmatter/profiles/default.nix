{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.profiles;
in
{
  imports = [
    ./winter
    ./frost
    ./blizzard
  ];
}
