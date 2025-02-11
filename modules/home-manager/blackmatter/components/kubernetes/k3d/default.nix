{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.blackmatter.components.kubernetes.k3d;
in
{
  options.blackmatter.components.kubernetes.k3d = {
    enable = mkEnableOption "Enable a default k3d cluster.";

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address where the default k3d cluster is accessible.";
    };

    port = mkOption {
      type = types.int;
      default = 6443;
      description = "The port where the default k3d cluster is accessible.";
    };

    client.enable = mkEnableOption "Enable client tools and KUBECONFIG management for k3d.";

    client.tools = mkOption {
      type = types.listOf types.str;
      default = [ "kubectl" "k9s" ];
      description = "List of client tools to install for interacting with the Kubernetes cluster.";
    };
  };

  config = mkIf cfg.enable {
    # Install k3d and optionally client tools
    home.packages = with pkgs; [
      k3d
    ] ++ lib.optionals cfg.client.enable (map (tool: pkgs.${tool}) cfg.client.tools);

    # Set KUBECONFIG environment variable
    home.sessionVariables = lib.mkIf cfg.client.enable {
      KUBECONFIG = "${config.home.homeDirectory}/.kube/config";
    };

    # Generate KUBECONFIG for the default cluster
    # home.file = lib.mkIf cfg.client.enable {
    #   ".kube/config".text = ''
    #     apiVersion: v1
    #     clusters:
    #     - cluster:
    #         insecure-skip-tls-verify: true
    #         server: https://${cfg.address}:${toString cfg.port}
    #       name: default
    #     contexts:
    #     - context:
    #         cluster: default
    #         user: default-user
    #       name: default-context
    #     current-context: default-context
    #     users:
    #     - name: default-user
    #       user:
    #         token: dummy-token
    #   '';
    # };

    # Define a systemd service for the default k3d cluster
    # systemd.user.services.k3d-default = {
    #   Service = {
    #     ExecStart = ''
    #       ${pkgs.k3d}/bin/k3d cluster create \
    #         --api-port ${cfg.address}:${toString cfg.port} \
    #         -p 80:80@loadbalancer
    #     '';
    #     ExecStop = "${pkgs.k3d}/bin/k3d cluster delete";
    #     Restart = "on-failure";
    #   };
    # };
  };
}
