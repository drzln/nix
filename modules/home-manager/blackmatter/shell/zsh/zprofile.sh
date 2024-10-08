! [ -d ~/.config/shellz ] && mkdir -p ~/.config/shellz

function load_shellz_mod() {
	[ -d ~/.config/shellz/$1 ] && source ~/.config/shellz/$1/main.sh
}

# disabled sections of zsh configuration
# rbenv
declare -a shellz_mods=(
	direnv
	path
	xdg
	nix
	tmux
	zstyle
	completions
	ssh_agent
)

for m in "${shellz_mods[@]}"; do
	load_shellz_mod $m
done

# load gh token from sops-nix location if exists
[ -e ~/.config/gh/env/GH_TOKEN ] && export GH_TOKEN=$(cat ~/.config/gh/env/GH_TOKEN)

# some aliases
alias grep=rg
alias cat=bat
