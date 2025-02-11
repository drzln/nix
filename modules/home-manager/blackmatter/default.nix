{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter;
in
{
  imports = [
    ./profiles
		./components
  ];

  options = {
    blackmatter = {
      enable = mkEnableOption "enable blackmatter";
    };
  };
}
