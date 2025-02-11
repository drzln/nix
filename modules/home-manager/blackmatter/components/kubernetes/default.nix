{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.kubernetes;

in
{
  imports = [
    ./k3d
  ];

  options = {
    blackmatter = {
      components = {
        kubernetes.enable = mkEnableOption "kubernetes";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        kind
        minikube
        helm
        kubectl
      ];
    })
  ];
}
