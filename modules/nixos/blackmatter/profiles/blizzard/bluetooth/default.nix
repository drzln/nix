# modules/nixos/blackmatter/profiles/blizzard/bluetooth/default.nix
{...}: {
  services.blueman.enable = true;
}
