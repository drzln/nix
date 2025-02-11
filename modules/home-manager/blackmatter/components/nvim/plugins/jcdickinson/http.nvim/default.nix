# EXAMPLE: a great example of building a rust plugin dependency
{ lib, config, pkgs, inputs, ... }:
with lib;
let
	cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  author = "jcdickinson";
  name = "http.nvim";
  plugName = "http";
  ref = "main";
  rev = import ./rev.nix;

  pkg = pkgs.rustPlatform.buildRustPackage rec {
    pname = name;
    inherit src;
    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.openssl.dev
    ];
    buildInputs = [ pkgs.openssl ];
    version = "unstable";
    cargoBuildFlags = [ "--workspace" ];
    postInstall = ''
      # Remove unnecessary files
      rm -rf $out/.cargo $out/.rustup
    '';
    cargoSha256 = "sha256-nvOjnjuwm2x487JAaQlngooQUquue4bKr8hnHEeD3Js=";

  };


in
{
  options.blackmatter.components.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source = pkg;
    })
  ];
}
