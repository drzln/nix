{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.goomba;
  global = config.blackmatter.components.goomba-global;
in

{
  imports = [
    ./host/network
    ./node/base
  ];

  options.blackmatter.components.goomba-global.enable = mkEnableOption "enable goomba system";
  options.blackmatter.components.goomba-global.bridge =
    {
      name = mkOption {
        type = types.str;
        description = "Name of the host network bridge.";
      };

      address = mkOption {
        type = types.str;
        description = "IP address of the host network bridge.";
      };

      prefix = mkOption {
        type = types.int;
        description = "IP prefix of the host network bridge.";
      };
    };

  # options.blackmatter.components.goomba = mkOption {
  #   description = "A submodule for managing multiple goomba instances for blackmatter.";
  #   type = types.submodule {
  #     # This is the default module instantiated for every instance.
  #     defaultModule = { config, ... }:
  #       let
  #         instanceName = config._name;
  #       in
  #       {
  #         options = {
  #           # enable = mkEnableOption "Enable this goomba instance";
  #           #
  #           # ip = {
  #           #   local = {
  #           #     address = mkOption {
  #           #       type = types.str;
  #           #       description = "Local IP address for this goomba instance.";
  #           #     };
  #           #
  #           #     prefix = mkOption {
  #           #       type = types.int;
  #           #       description = "Local IP prefix for this goomba instance.";
  #           #     };
  #           #   };
  #           # };
  #         };
  #
  #         config = {
  #           # For example, create a container for this goomba instance.
  #           # containers."${instanceName}" = mkIf config.enable {
  #           #   localAddress = "${config.ip.local.address}/${toString config.ip.local.prefix}";
  #           #   # Additional per-instance configuration can go here.
  #           # };
  #         };
  #       };
  #   };
  #
  # };

  config = mkMerge [
    (mkIf global.enable {
      blackmatter.components.goomba.host.network.enable = true;
      blackmatter.components.goomba.host.network.bridge = config.blackmatter.components.goomba-global.bridge;
    })
  ];
}

