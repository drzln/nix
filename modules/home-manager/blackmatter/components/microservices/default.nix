{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.microservices;
in
{
  imports =
    [
      ./minio
    ];

  options = {
    blackmatter = {
      components = {
        microservices = {
          enable = mkEnableOption "microservices";
        };
      };
    };
  };

  # in case we do find anything global about microservices
  config = mkMerge [
    (mkIf cfg.enable { })
  ];
}
