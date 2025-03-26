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
        sheldon
        zoxide
        xsel
        bat
      ];
      home.file.".config/sheldon/plugins.toml".text = ''
        # ~/.config/sheldon/plugins.toml - Sheldon plugin definitions

        # Plugins are organized by name under the [plugins] table.

        [plugins.zsh-autosuggestions]
        github = "zsh-users/zsh-autosuggestions"
        tag = "v0.7.0"  # pin to a known stable release for consistency
        use = ["zsh-autosuggestions.zsh"]
        hooks.post = "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4c566a"

        [plugins.zsh-syntax-highlighting]
        github = "zsh-users/zsh-syntax-highlighting"
        # (Always load this last for proper behavior) [oai_citation_attribution:21‡github.com](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#:~:text=Note%20the%20,zshrc)
        use = ["zsh-syntax-highlighting.zsh"]

        [plugins.fzf]
        github = "junegunn/fzf"
        tag = "0.60.3"  # lock to a specific release of fzf for stable scripts
        use = [ "shell/key-bindings.zsh", "shell/completion.zsh" ]
        # (fzf binary is expected to be installed separately in $PATH)
      '';
      home.file.".zshrc".text = ''
        # XDG vars
        export XDG_CONFIG_HOME=~/.local/config
        export XDG_STATE_HOME=~/.local/state
        export XDG_DATA_HOME=~/.local/share

        # History
        export HISTFILE=~/.zsh_history
        export HISTSIZE=10000000
        export SAVEHIST=10000000


        # Aliases
        alias vimdiff=nvim -d -u ~/.config/nvim/init.lua
        alias vim=nvim -u ~/.config/nvim/init.lua
        alias cat=bat
        alias cd=z

        if [[ "$(uname)" == "Linux" ]]; then
          alias pbpaste=xsel --clipboard --output
          alias pbcopy=xsel --clipboard --input
        fi

        # Sheldon
        eval "$(sheldon source)"

        # Completion
        # autoload -Uz compinit && compinit -i


        # zoxide manual integration
        # eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # direnv
        export DIRENV_LOG_FORMAT=""
        eval "$(direnv hook zsh)"

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
