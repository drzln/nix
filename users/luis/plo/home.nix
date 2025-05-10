# users/luis/plo/home.nix
{...}: {
  imports = [
    ../../common.nix
    ../../luis/common.nix
    ./blackmatter.nix
    ./packages.nix
    ./secrets
  ];
}
