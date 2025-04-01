{
  lib,
  pkgs,
  config,
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
      home.packages = with pkgs;
        [
          cfg.package
          google-java-format
          terraform
          zoxide
          wl-copy
          ruby
          bash
          xsel
          php
          fzf
          git
          fd
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [julia];
      home.file.".config/sheldon/plugins.toml".text = ''
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

        if [[ "$(uname)" == "Linux" ]]; then
          # If Wayland is detected
          if [[ -n "$WAYLAND_DISPLAY" ]]; then
            alias pbcopy='wl-copy'
            alias pbpaste='wl-paste'
          # Else if X11 is available
          elif [[ -n "$DISPLAY" ]]; then
            alias pbcopy='xsel --clipboard --input'
            alias pbpaste='xsel --clipboard --output'
          fi
        fi

        # Completion (must come before plugin init that registers completions)
        autoload -Uz compinit && compinit -i

        # FZF configuration
        export FZF_DEFAULT_COMMAND='${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
        export FZF_ALT_C_COMMAND='${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
        export FZF_CTRL_T_COMMAND='${pkgs.fd}/bin/fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix'
        export FZF_DEFAULT_OPTS="--height 20% --layout=reverse --border --ansi"

        # direnv and zoxide integrations
        export DIRENV_LOG_FORMAT=""
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        # starship prompt (should be last to fully control the prompt)
        eval "$(${pkgs.starship}/bin/starship init zsh)"

        # Vim keybindings
        bindkey -v

        # Load plugins via Sheldon (zsh-autosuggestions, syntax-highlighting, fzf)
        eval "$(${pkgs.sheldon}/bin/sheldon source)"
      '';
    })
  ];
}
