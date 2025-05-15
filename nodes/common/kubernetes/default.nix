{...}: {
  blackmatter.components.kubernetes = {
    enable = true;
    role = "single";
    kubelet.enable = true;
  };
}
