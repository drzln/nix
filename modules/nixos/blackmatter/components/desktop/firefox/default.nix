{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop.firefox;
  nord-web-theme = pkgs.stdenv.mkDerivation {
    name = "nord-web-theme";
    src = ./extensions/nord.xpi;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/lib/firefox/browser/extensions
      cp ${./extensions/nord.xpi} $out/lib/firefox/browser/extensions/nord.xpi
    '';
  };
in
{
  options = {
    blackmatter = {
      components = {
        desktop.firefox.enable = mkEnableOption "desktop.firefox";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.firefox = {
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
          # results in unexpected argument when used
          # forceWayland = false;
          extraPolicies = {
            ExtensionSettings = {
              "nord-web-theme@pleme.io" = {
                installation_mode = "force_installed";
                install_url = "file://${nord-web-theme}/lib/firefox/browser/extensions/nord.xpi";
              };
            };
          };
        };
      };
    })
  ];
}
