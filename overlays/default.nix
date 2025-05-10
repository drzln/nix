# overlays/default.nix
[
  # Example overlay: override hello
  (final: prev: {
    hello = prev.hello.overrideAttrs (old: {
      name = "hello-drzzln";
    });
  })

  # You can add more overlays here
]
