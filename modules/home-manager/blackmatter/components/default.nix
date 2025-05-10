{
  lib,
  # config,
  ...
}:
with lib; let
  # cfg = config.blackmatter.components;
in {
  imports = [
    ./microservices
  ];

  options = {
    blackmatter = {
      components = {
        enable = mkEnableOption "enable blackmatter components";
      };
    };
  };
}
