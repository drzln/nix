{ ... }:
let
in
{
  options = { };
  config = {
    # home.file.".local/share/nvim/site/srcs/tree-sitter/tree-sitter-c".source =
    #   builtins.fetchGit {
    #     url = "https://github.com/tree-sitter/tree-sitter-c";
    #     ref = "master";
    #     rev = import ./rev.nix;
    #   };
  };
}
