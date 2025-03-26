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

        [plugins.zsh-autosuggestions]
        apply = "source"
        github = "zsh-users/zsh-autosuggestions"
        use = ["zsh-autosuggestions.zsh"]
        hooks.post = 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4c566a"'

        [plugins.zsh-syntax-highlighting]
        apply = "source"
        github = "zsh-users/zsh-syntax-highlighting"
        use = ["zsh-syntax-highlighting.zsh"]

        [plugins.fzf]
        apply = "source"
        github = "junegunn/fzf"
        use = [ "shell/key-bindings.zsh", "shell/completion.zsh" ]
      '';
      home.file.".zshrc".text = ''
        # ~/.zshrc - Zsh configuration (Sheldon-managed plugins, Nord theme)

        # History
        export HISTFILE=~/.zsh_history
        export HISTSIZE=10000000
        export SAVEHIST=10000000

        # aliases
        alias vimdiff=nvim -d -u ~/.config/nvim/init.lua
        alias vim=nvim -u ~/.config/nvim/init.lua
        alias cat=bat
        alias cd=z

        if [[ "$(uname)" == "Linux" ]]; then
          alias pbpaste=xsel --clipboard --output
          alias pbcopy=xsel --clipboard --input
        fi

        # fzf
        if command -v fd >/dev/null; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
          export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix'
        fi

        # direnv and zoxide integrations
        export DIRENV_LOG_FORMAT=""
        eval "$(direnv hook zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # completion
        autoload -Uz compinit && compinit -i

        # starship
        # export STARSHIP_CONFIG=~/.config/starship.toml
        eval "$(starship init zsh)"

        # sheldon
        eval "$(sheldon source)"

        # move with vim
        bindkey -v
      '';
      # programs.zoxide = {
      #   enable = true;
      #   enableZshIntegration = false;
      # };
    })
  ];
}
