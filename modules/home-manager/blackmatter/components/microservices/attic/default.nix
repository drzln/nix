{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.attic;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the Attic binary cache service";
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Namespace for the Attic service instance.
        Useful for distinguishing multiple instances or environments.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.attic;
      description = mdDoc "Attic package to use for the binary cache server";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {
        # Example default settings; adjust these as needed.
        listen = "[::]:8080";
        # You can include other Attic configuration settings here,
        # such as backend storage settings, chunking parameters, etc.
      };
      description = mdDoc "Dynamic Attic settings to override defaults (if non-empty)";
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          attic = interface;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Configure the Attic service (atticd) using the defined options.
      # services.atticd = {
      #   enable = true;
      #   package = cfg.package;
      #   namespace = cfg.namespace;
      #   settings = cfg.settings;
      # };
    })
  ];
}

