# settings for the host network
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.goomba.host.network;
in
{
  options.blackmatter.components.goomba.host.network = {
    enable = mkEnableOption "enable goomba network settings";

    bridge.name = mkOption {
      type = types.str;
    };

    bridge.address = mkOption {
      type = types.str;
    };

    bridge.prefix = mkOption {
      type = types.int;
    };

    dns.addresses = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
    })
  ];
}
