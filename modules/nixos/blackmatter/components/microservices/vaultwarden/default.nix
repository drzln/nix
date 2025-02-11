{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.blackmatter.components.microservices.vaultwarden;

  interface = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Vaultwarden password manager service";
    };

    namespace = mkOption {
      type = types.str;
      default = "vaultwarden";
      description = mdDoc ''
        Logical namespace for vaultwarden instance (e.g., for container orchestration)
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.vaultwarden;
      description = mdDoc "Vaultwarden package to use";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = mdDoc ''
        Configuration settings that map directly to services.vaultwarden.config options.
        See NixOS options for full documentation.
      '';
    };
  };
in
{
  options = {
    blackmatter = {
      components = {
        microservices = {
          vaultwarden = interface;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      inherit (cfg) package;
      config = cfg.settings;
    };

    # Optional: Add namespace-aware networking configuration
    # networking.firewall.interfaces."${cfg.namespace}" = {
    #   allowedTCPPorts = [ 80 443 ]; # Example port configuration
    # };
  };
}
