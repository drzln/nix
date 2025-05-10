# parts/overlays.nix
{inputs, ...}: {
  flake.overlays =
    builtins.attrValues inputs.sops-nix.overlays
    ++ import ../overlays
    ++ [
      (final: prev: {
        # extra custom packages here
      })
    ];
}
