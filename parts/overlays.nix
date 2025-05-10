# parts/overlays.nix
{inputs, ...}: let
  myOverlays =
    [
      # Optional: pick specific overlay from sops-nix
      inputs.sops-nix.overlays.default
    ]
    ++ import ../overlays # <- imports the list you defined above
    ++ [
      # Inline extra overlay (optional)
      (final: prev: {
        # custom = ...;
      })
    ];
in {
  flake.overlays = {
    combined = final: prev:
      builtins.foldl' (acc: o: acc // o final prev) {} myOverlays;
  };
}
