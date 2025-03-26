{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.zsh;
in {
  options = {
    blackmatter = {
      components = {
        shell.zsh.enable = mkEnableOption "shell.zsh";
        shell.zsh.package = mkOption {
          type = types.package;
          default = pkgs.zsh;
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        cfg.package
        zoxide
        direnv
        xsel
        bat
      ];
      home.file.".zshrc".text = ''
        # XDG vars
        export XDG_STATE_HOME=~/.local/state
        export XDG_DATA_HOME=~/.local/share
        export XDG_CONFIG_HOME=~/.local/config

        # History
        export HISTSIZE=10000000
        export SAVEHIST=10000000
        export HISTFILE=~/.zsh_history

        # Completion
        autoload -Uz compinit && compinit -i


        # Aliases
        alias vimdiff=nvim -d -u ~/.config/nvim/init.lua
        alias vim=nvim -u ~/.config/nvim/init.lua
        alias cat=bat
        alias cd=z

        if [[ "$(uname)" == "Linux" ]]; then
          alias pbpaste=xsel --clipboard --output
          alias pbcopy=xsel --clipboard --input
        fi

        # zoxide manual integration
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # direnv
        export DIRENV_LOG_FORMAT=""
        eval "$(${pkgs.direnv} hook zsh)"

        # fzf
        # === Inline fzf config ===

        # Set default command to use fd (if available), fall back to find
        if command -v fd &>/dev/null; then
          export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
          export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix'
        else
          export FZF_DEFAULT_COMMAND='find . -type f'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
          export FZF_ALT_C_COMMAND='find . -type d'
        fi
        
        # FZF options
        export FZF_DEFAULT_OPTS='
          --height 40%
          --layout=reverse
          --border
          --color=fg:#bbbbbb,bg:-,hl:#88c0d0
          --color=fg+:#eeeeee,bg+:-,hl+:#8fbcbb
          --color=info:#b48ead,prompt:#a3be8c,pointer:#d08770
          --color=marker:#ebcb8b,spinner:#bf616a,header:#81a1c1
        '
        
        # Ctrl-T for file insert
        fzf-file-widget() {
          local selected
          selected=$(eval "$FZF_CTRL_T_COMMAND" | fzf --multi) || return
          LBUFFER+="$selected"
          zle redisplay
        }
        zle -N fzf-file-widget
        bindkey '^T' fzf-file-widget
        
        # Alt-C to change dir
        fzf-cd-widget() {
          local dir
          dir=$(eval "$FZF_ALT_C_COMMAND" | fzf +m) && cd "$dir"
          zle reset-prompt
        }
        zle -N fzf-cd-widget
        bindkey '^[c' fzf-cd-widget

        # starship
        # export STARSHIP_CONFIG=~/.config/starship.toml
        # eval "$(starship init zsh)"


        # === Minimal Inline Autosuggestions ===
        # ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
        # autoload -Uz add-zsh-hook

        # _zsh_autosuggest_widget() {
        #   BUFFER="''${BUFFER}$(builtin fc -rl 1 | grep -F -- "''${BUFFER}" | head -n1 | sed "s/^''${BUFFER}//")"
        #   zle redisplay
        # }

        # _zsh_autosuggest_bind() {
        #   zle -N autosuggest-accept _zsh_autosuggest_widget
        #   bindkey '^F' autosuggest-accept
        # }

        # add-zsh-hook precmd _zsh_autosuggest_bind

        # === Minimal Inline Syntax Highlighting ===
        # autoload -Uz colors && colors
        # setopt PROMPT_SUBST
        # PS1='%F{green}%n@%m%f %F{blue}%~%f %# '

        # zle_highlight=('default:bold' 'unknown:red' 'reserved:standout')

        # preexec() {
        #   echo -ne "\\e[0m"
        # }

        # typeset -A HIGHLIGHT_COLORS
        # HIGHLIGHT_COLORS[valid]=''$fg[green]
        # HIGHLIGHT_COLORS[invalid]=''$fg[red]
        # HIGHLIGHT_COLORS[flag]=''$fg[blue]
        # HIGHLIGHT_COLORS[string]=''$fg[yellow]
        # HIGHLIGHT_COLORS[reset]=''$reset_color

        # _zsh_inline_highlight() {
        #   local buffer="''${BUFFER}"
        #   local words=("''${(z)buffer}")
        #   local new_buffer=""
        #   local i=1
        #
        #   for word in "''${words[@]}"; do
        #     if [[ "''${i}" -eq 1 ]]; then
        #       if whence -w -- "''${word}" &>/dev/null; then
        #         new_buffer+="''${HIGHLIGHT_COLORS[valid]}''${word}''${HIGHLIGHT_COLORS[reset]}"
        #       else
        #         new_buffer+="''${HIGHLIGHT_COLORS[invalid]}''${word}''${HIGHLIGHT_COLORS[reset]}"
        #       fi
        #     elif [[ "''${word}" =~ '^-' ]]; then
        #       new_buffer+=" ''${HIGHLIGHT_COLORS[flag]}''${word}''${HIGHLIGHT_COLORS[reset]}"
        #     elif [[ "''${word}" =~ '^\".*\"$' || "''${word}" =~ "^'.*'$" ]]; then
        #       new_buffer+=" ''${HIGHLIGHT_COLORS[string]}''${word}''${HIGHLIGHT_COLORS[reset]}"
        #     else
        #       new_buffer+=" ''${word}"
        #     fi
        #     ((i++))
        #   done
        #
        #   echo -ne "\\r\\033[K''${new_buffer}"
        # }

        # _zsh_inline_highlight_bind() {
        #   zle -N zle-line-pre-redraw _zsh_inline_highlight
        # }

        # add-zsh-hook precmd _zsh_inline_highlight_bind
      '';
      programs.zoxide = {
        enable = true;
        enableZshIntegration = false;
      };
    })
  ];
}
