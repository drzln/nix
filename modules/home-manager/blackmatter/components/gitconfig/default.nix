{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.gitconfig;
in
{
  options = {
    blackmatter = {
      components = {
        gitconfig.enable = mkEnableOption "blackmatter.gitconfig";

        gitconfig.email = mkOption {
          type = types.str;
          description = mdDoc "gitconfig user email";
        };

        gitconfig.user = mkOption {
          type = types.str;
          description = mdDoc "gitconfig user";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.file.".gitconfig".text = ''
        [user]
        	email = ${cfg.email}
        	name = ${cfg.user}

        [init]
        	defaultBranch = main

        [push]
        	default = simple

        [branch "main"]
        	remote = origin
        	merge = refs/head/main

        [merge]
        	default = merge

        [core]
        	pager = delta --dark --line-numbers
        	editor = nvim

        [delta]
        	side-by-side = true
      '';
    })
  ];
}
