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
        fzf
      ];
      home.file.".config/sheldon/plugins.toml".text = ''
        # ~/.config/sheldon/plugins.toml - Sheldon plugin definitions
        shell = "zsh"

        [plugins.base16]
        github = "chriskempson/base16-shell"

        [plugins.zsh-autosuggestions]
        github = "zsh-users/zsh-autosuggestions"
        use = ["zsh-autosuggestions.zsh"]

        [plugins.zsh-syntax-highlighting]
        github = "zsh-users/zsh-syntax-highlighting"
        use = ["zsh-syntax-highlighting.zsh"]

        [plugins.fzf]
        github = "junegunn/fzf"
        use = [ "shell/key-bindings.zsh", "shell/completion.zsh" ]
      '';
      home.file.".zshrc".text = ''
        # ~/.zshrc - Zsh configuration (Sheldon-managed plugins, Nord theme)

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

        # Completion (must come before plugin init that registers completions)
        autoload -Uz compinit && compinit -i

        # FZF configuration
        if command -v fd >/dev/null; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix'
        fi

        export FZF_DEFAULT_OPTS = "--height 20% --layout=reverse --border --ansi"
        # export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --ansi \
        #   --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1 \
        #   --color=fg+:#e5e9f0,bg+:#434c5e,hl+:#88c0d0 \
        #   --color=info:#8fbcbb,prompt:#81a1c1,pointer:#bf616a \
        #   --color=marker:#ebcb8b,spinner:#b48ead,header:#81a1c1"

        # direnv and zoxide integrations
        export DIRENV_LOG_FORMAT=""
        eval "$(direnv hook zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # starship prompt (should be last to fully control the prompt)
        eval "$(starship init zsh)"

        # Vim keybindings
        bindkey -v

        # Load plugins via Sheldon (zsh-autosuggestions, syntax-highlighting, fzf)
        eval "$(${pkgs.sheldon}/bin/sheldon source)"
      '';
    })
  ];
}
