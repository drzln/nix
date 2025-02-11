prog :=xnixperms

rebuild:
	bin/nixos-rebuild
	bin/home-manager-rebuild

nixos-rebuild:
	bin/nixos-rebuild

darwin-rebuild:
	bin/darwin-rebuild

home-manager-rebuild:
	bin/home-manager-rebuild

build-neovim:
	nix build .#packages.neovim_drzln.x86_64-linux

build-nixhashsync:
	nix build .#packages.nixhashsync.x86_64-linux
