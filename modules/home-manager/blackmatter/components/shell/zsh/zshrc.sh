###############################################################################
# zsh config
###############################################################################

! [ -d ~/.config/shellz ] && mkdir -p ~/.config/shellz

function load_shellz_mod() {
	[ -d ~/.config/shellz/"$1" ] && source ~/.config/shellz/$1/main.sh
}

declare -a shellz_mods=(
	direnv
)

for m in "${shellz_mods[@]}"; do
	load_shellz_mod $m
done

# vim movement
bindkey -v
