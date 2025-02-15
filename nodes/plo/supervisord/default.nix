{requirements, ...}: let
  namespace = "plo";
in {
  imports = [
    requirements.inputs.self.nixosModules.blackmatter
  ];

  blackmatter.components.microservices.supervisord = {
    inherit namespace;
    enable = false;
  };
}
