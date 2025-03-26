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

        [plugins.zsh-autosuggestions]
        github = "zsh-users/zsh-autosuggestions"
        tag = "v0.7.0"  # pin to a known stable release for consistency
        use = ["zsh-autosuggestions.zsh"]
        hooks.post = 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4c566a"'

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
        # ~/.zshrc - Zsh configuration (Sheldon-managed plugins, Nord theme)

        # History
        export HISTFILE=~/.zsh_history
        export HISTSIZE=10000000
        export SAVEHIST=10000000

        # XDG vars
        # export XDG_CONFIG_HOME=~/.local/config
        # export XDG_STATE_HOME=~/.local/state
        # export XDG_DATA_HOME=~/.local/share

        # Aliases
        alias vimdiff=nvim -d -u ~/.config/nvim/init.lua
        alias vim=nvim -u ~/.config/nvim/init.lua
        alias cat=bat
        alias cd=z

        if [[ "$(uname)" == "Linux" ]]; then
          alias pbpaste=xsel --clipboard --output
          alias pbcopy=xsel --clipboard --input
        fi

        # 2. FZF configuration: use `fd` for fast searching, and apply Nord color scheme
        if command -v fd >/dev/null; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix'
        fi

        # Nord theme colors for fzf UI (matching Nord palette)
        # [oai_citation_attribution:16‡github.com]
        # (https://github.com/ianchesal/nord-fzf#:~:text=export%20FZF_DEFAULT_OPTS%3D%24FZF_DEFAULT_OPTS%27%20,a3be8b)

        export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --ansi $FZF_DEFAULT_OPTS \
          --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1 \
          --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1 \
          --color=info:#eacb8a,prompt:#bf616a,pointer:#b48dac \
          --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b"

        # (Sheldon will have loaded zsh-autosuggestions and applied our configured post-hook
        # for Nord suggestions, and loaded zsh-syntax-highlighting last.)

        # 4. Enable direnv and zoxide integrations
        export DIRENV_LOG_FORMAT=""
        eval "$(direnv hook zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # Completion
        autoload -Uz compinit && compinit -i

        # starship
        # export STARSHIP_CONFIG=~/.config/starship.toml
        eval "$(starship init zsh)"

        # Sheldon
        eval "$(sheldon source)"

        # move with vim
        bind -v
      '';
      # programs.zoxide = {
      #   enable = true;
      #   enableZshIntegration = false;
      # };
    })
  ];
}
