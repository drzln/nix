# enable vim movements on the command line
bindkey -v

# === History Settings ===
export HISTFILE=$HOME/.local/state/.zsh_history
export HISTSIZE=10000000000
export SAVEHIST=10000000000

# === Completion ===
autoload -Uz compinit
compinit

# === Syntax Highlighting (manual install assumed) ===
# source /path/to/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# === Autosuggestions (manual install assumed) ===
# source /path/to/zsh-autosuggestions/zsh-autosuggestions.zsh

# === Enable Zoxide ===
eval "$(zoxide init zsh)"

# === Shell Aliases ===
alias vim='nvim -u ~/.config/nvim/init.lua'
alias vimdiff='nvim -d -u ~/.config/nvim/init.lua'
alias cat='bat'
alias cd='z'

# Linux-specific clipboard fallback (you can check this conditionally in Zsh too)
if [[ "$(uname)" == "Linux" ]]; then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi
