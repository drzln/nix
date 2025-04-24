{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.kubernetes;

  # Your kubernetes overlay / packages (optional, leave out if not needed)
  overlay = cfg.overlay or inputs.nix-kubernetes.overlays.default;
  pkgs = import inputs.nixpkgs {
    system = pkgs.system;
    overlays = [overlay];
  };
in {
  ### ───── options ───────────────────────────────────────────────────────────
  options.blackmatter.components.kubernetes = {
    enable = mkEnableOption "Enable the Kubernetes stack";

    role = mkOption {
      type = types.enum ["master" "worker" "single"];
      default = "single";
      description = "Node role in the cluster. 'single' = all-in-one.";
    };

    # namespace = mkOption {
    #   type = types.str;
    #   default = "default";
    #   description = "Namespace prefix used for auxiliary services.";
    # };

    # overlay = mkOption {
    #   type = types.nullOr types.attrs;
    #   default = null;
    #   description = "Overlay providing custom Kubernetes / etcd / containerd builds.";
    # };
  };

  ###########################################################################
  # Configuration
  ###########################################################################
  config = mkIf cfg.enable (mkMerge [
    #######################################
    # Kubernetes core (placeholder)
    #######################################
    {
      # … put master/worker/single logic here …
      # e.g. services.kubernetes roles, packages, etc.
    }

    #######################################
    # Traefik binding
    #######################################
    # (mkIf cfg.reverseProxy.traefik.enable {
    #   blackmatter.components.microservices.traefik = {
    #     enable = true;
    #     namespace = cfg.namespace;
    #     package = cfg.reverseProxy.traefik.package;
    #     settings = cfg.reverseProxy.traefik.settings;
    #   };
    # })

    #######################################
    # Consul binding
    #######################################
    # (mkIf cfg.reverseProxy.consul.enable {
    #   blackmatter.components.microservices.consul = {
    #     enable = true;
    #     namespace = cfg.namespace;
    #     package = cfg.reverseProxy.consul.package;
    #   };
    # })

    #######################################
    # Nomad binding
    #######################################
    # (mkIf cfg.reverseProxy.nomad.enable {
    #   blackmatter.components.microservices.nomad = {
    #     enable = true;
    #     namespace = cfg.namespace;
    #     package = cfg.reverseProxy.nomad.package;
    #   };
    # })
  ]);
}
