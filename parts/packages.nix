# parts/packages.nix
{inputs, ...}: {
  systems = ["x86_64-linux"];
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = {
      neovim = pkgs.callPackage ../pkgs/neovim {};
      kubectl = inputs.nix-kubernetes.packages.${system}.kubectl;
    };

    devShells.default = pkgs.mkShell {
      buildInputs = [pkgs.git pkgs.hello];
    };
  };
}
