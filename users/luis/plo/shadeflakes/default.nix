{ lib, ... }: {
  home.activation.createCodeCommitDir = lib.mkAfter ''
    		mkdir -p $HOME/code/codecommit/pinger
    		chmod 700 $HOME/code/codecommit/pinger
    	'';

  home.file."code/codecommit/pinger/shadeflake.nix" = {
    source = ./code/codecommit/pinger/flake.nix;
  };

  home.file."code/codecommit/pinger/.envrc" = {
    source = ./code/codecommit/pinger/.envrc.default;
  };
}
