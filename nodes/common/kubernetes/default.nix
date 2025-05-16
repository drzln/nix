{...}: {
  imports = [
    ./secrets.nix
  ];
  blackmatter.components.kubernetes = {
    enable = true;
    role = "single";
  };
}
