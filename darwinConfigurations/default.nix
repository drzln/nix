# darwinConfigurations/default.nix
{
  home-manager,
  nix-darwin,
  inputs,
  pkgs,
}: {
  cid = nix-darwin.lib.darwinSystem {
    system = "x86_64-darwin";
    modules = [
      home-manager.darwinModules.home-manager
      ../nodes/cid
    ];
    specialArgs = {
      inherit inputs pkgs;
    };
  };
}
