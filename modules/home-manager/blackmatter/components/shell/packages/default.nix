{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in {
  options = {
    blackmatter = {
      components = {
        shell.packages.enable =
          mkEnableOption "shell.packages";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs;
        [ripgrep]
        ++ lib.optionals isDarwin []
        ++ lib.optionals isLinux [
          sumneko-lua-language-server
          nix-prefetch-git
          attic-client
          openconnect
          traceroute
          llama-cpp
          gnumake
          awscli2
          lazygit
          bundix
          zoxide
          delta
          cargo
          arion
          sops
          xsel
          nmap
          tree
          dig
          fzf
          tor
          gh
        ];
    })
  ];
}
