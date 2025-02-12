{ nix-darwin, home-manager, inputs, darwin-pkgs }: {
  cid = nix-darwin.lib.darwinSystem {
    system = "x86_64-darwin";
    modules = [
      home-manager.darwinModules.home-manager
			../nodes/cid
    ];
    specialArgs = {
      inherit inputs;
      pkgs = darwin-pkgs;
    };
  };
}
