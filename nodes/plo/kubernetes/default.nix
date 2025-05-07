{...}: {
  blackmatter.components.kubernetes = {
    enable = true;
    role = "single";
    staticControlPlane.enable = true;
  };
}
