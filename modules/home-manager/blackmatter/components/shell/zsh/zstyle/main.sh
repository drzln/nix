zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2 numeric
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
