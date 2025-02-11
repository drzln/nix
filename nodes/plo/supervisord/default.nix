{ requirements, ... }:
let
  namespace = "plo";
in
{
  imports = [
    requirements.outputs.nixosModules.blackmatter
  ];

  blackmatter.components.microservices.supervisord = {
    inherit namespace;
    enable = false;
  };
}
