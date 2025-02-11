{ config, lib, ... }:
with lib;
let
  # establish module scope
  cfg = config.blackmatter.envrc;

  # if a directory exists place an .envrc
  # in the directory
  envrc = directory: envrc-path:
    if builtins.pathExists directory && (
      builtins.exec
        {
          command = "git";
          args = [ "rev-parse" "HEAD" ];
          cwd = directory;
          ignoreErrors = true;
        } != ""
    ) then
      builtins.symlinkJoin
        {
          name = "${directory}-envrc";
          target = envrc-path;
        }
    else null;

  options = {
    blackmatter = {
      envrc = {
        enable = mkEnableOption "blackmatter envrc";
      };
    };
  };

  # module actions
  actions = mkMerge [
    (mkIf cfg.enable { })
  ];

  # wrap the module up
  module = {
    inherit options;
    config = actions;
  };
in

# return the module
module
