{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.shell.starship;
in
{
  options = {
    blackmatter = {
      components = {
        shell.starship.enable = mkEnableOption "shell.starship";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.starship.enable = true;
      programs.starship.settings = {
        add_newline = false;
        format = ''
          $hostname $directory $git_branch$git_status$git_state(bold blue)
          [$character](bold blue)
        '';
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[✖](bold red) ";
          vicmd_symbol = "[#](bold green)";
          disabled = false;
        };
        cmake = { disabled = true; };
        package = { disabled = true; };
        aws = { disabled = true; };
        battery = { disabled = true; };
        cmd_duration = { disabled = true; };
        conda = { disabled = true; };
        dart = { disabled = true; };
        deno = { disabled = true; };
        docker_context = { disabled = true; };
        dotnet = { disabled = true; };
        elixir = { disabled = true; };
        elm = { disabled = true; };
        erlang = { disabled = true; };
        gcloud = { disabled = true; };
        golang = { disabled = true; };
        helm = { disabled = true; };
        java = { disabled = true; };
        jobs = { disabled = true; };
        julia = { disabled = true; };
        kotlin = { disabled = true; };
        kubernetes = { disabled = true; };
        line_break = { disabled = true; };
        memory_usage = { disabled = true; };
        nim = { disabled = true; };
        nix_shell = { disabled = true; };
        nodejs = { disabled = true; };
        ocaml = { disabled = true; };
        openstack = { disabled = true; };
        perl = { disabled = true; };
        php = { disabled = true; };
        purescript = { disabled = true; };
        python = { disabled = false; };
        red = { disabled = true; };
        ruby = { disabled = true; };
        rust = { disabled = true; };
        scala = { disabled = true; };
        shell = { disabled = true; };
        shlvl = { disabled = true; };
        singularity = { disabled = true; };
        status = { disabled = true; };
        swift = { disabled = true; };
        terraform = { disabled = true; };
        time = { disabled = true; };
        username = { disabled = true; };
        vcsh = { disabled = true; };
        zig = { disabled = true; };
        git_branch = {
          disabled = false;
          style = "bold dimmed cyan";
        };
        git_state = {
          disabled = false;
          format = ''
            [\($state( $progress_current of $progress_total)\)]($style) 
          '';
        };
        git_status = {
          disabled = false;
          conflicted = "⚔️ ";
        };
        hostname = {
          ssh_only = false;
          format = "<[$hostname]($style)>";
          trim_at = "-";
          style = "bold dimmed green";
          disabled = false;
        };
        directory = {
          truncation_length = 2;
          format = "[$path]($style)[$lock_symbol]($lock_style)";
          disabled = false;
          style = "bold dimmed green";
        };
      };
    })
  ];
}
