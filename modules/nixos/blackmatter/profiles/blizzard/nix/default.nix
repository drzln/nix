# modules/nixos/blackmatter/profiles/blizzard/nix/default.nix
{pkgs, ...}: {
  nix = {
    gc = {automatic = false;};
    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
    '';
    settings = {
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      substituters = ["https://hyprland.cachix.org"];
      auto-optimise-store = true;
      keep-derivations = true;
      keep-outputs = true;
    };
    package = pkgs.nixVersions.stable;
  };
}
