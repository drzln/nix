{ lib, requirements, ... }:
let
  # devenv-config = rec {
  #   home.path = "/devenv";
  #   services.path = "/devenv";
  #   minio.path = "${devenv-config.services.path}/minio";
  # };

  # attic-implementation = {
  #   enable = true;
  # };

  # minio-implementation = {
  #   enable = true;
  #   dataDir = [ "${devenv-config.minio.path}" ];
  # };
in
{
  # imports = [
  #   requirements.outputs.nixosModules.blackmatter
  # ];
  # system.activationScripts.devenvprereqs = lib.mkBefore ''
  #   mkdir -p ${devenv-config.home.path} || true
  #   mkdir -p ${devenv-config.minio.path} || true
  # '';
  # blackmatter.components.microservices.attic = attic-implementation;
  # blackmatter.components.microservices.minio = minio-implementation;
}
