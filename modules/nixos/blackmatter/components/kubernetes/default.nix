# {
#   lib,
#   config,
#   # pkgs,
#   # inputs,
#   ...
# }:
# with lib; let
#   cfg = config.blackmatter.components.kubernetes;
#   # overlay = cfg.overlay or inputs.nix-kubernetes.overlays.default;
#
#   # pkgs' = import inputs.nixpkgs {
#   #   system = pkgs.system;
#   #   overlays = [overlay];
#   # };
#
#   # k8sPkgs =
#   #   pkgs'.kubernetesPackages
#   #   // {
#   #     kube-apiserver = pkgs'.kube-apiserver;
#   #     kube-controller-manager = pkgs'.kube-controller-manager;
#   #     kube-scheduler = pkgs'.kube-scheduler;
#   #   };
#
#   # etcdPkg = cfg.etcdPackage or pkgs'.etcd;
#   # containerdPkg = cfg.containerdPackage or pkgs'.containerd;
#
#   isMaster = cfg.role == "master" || cfg.role == "single";
#   isWorker = cfg.role == "worker" || cfg.role == "single";
# in {
#   options.blackmatter.components.kubernetes = {
#     enable = mkEnableOption "Enable Kubernetes on this host";
#
#     role = mkOption {
#       type = types.enum ["master" "worker" "single"];
#       default = "single";
#       description = "Node role in the cluster; 'single' = control-plane + worker.";
#     };
#
#     overlay = mkOption {
#       type = types.nullOr types.attrs;
#       default = null;
#       description = "Overlay providing custom Kubernetes / etcd / containerd builds.";
#     };
#
#     etcdPackage = mkOption {
#       type = types.nullOr types.package;
#       default = null;
#       description = "Override etcd derivation (defaults to overlay’s etcd).";
#     };
#
#     containerdPackage = mkOption {
#       type = types.nullOr types.package;
#       default = null;
#       description = "Override containerd derivation.";
#     };
#
#     nodePortRange = mkOption {
#       type = types.str;
#       default = "30000-32767";
#       description = "service-node-port-range passed to kube-apiserver.";
#     };
#
#     extraApiArgs = mkOption {
#       type = types.attrsOf types.str;
#       default = {};
#       description = "Additional kube-apiserver --extra-args.";
#     };
#
#     extraKubeletOpts = mkOption {
#       type = types.str;
#       default = "";
#       description = "Extra CLI options appended to kubelet.extraOpts.";
#     };
#
#     kubeadmExtra = mkOption {
#       type = types.attrs;
#       default = {};
#       description = "Attrset merged into services.kubernetes.kubeadm.extraConfig.";
#     };
#
#     firewallOpen = mkOption {
#       type = types.bool;
#       default = false;
#       description = "If true, leaves the NixOS firewall enabled.";
#     };
#
#     join = {
#       address = mkOption {
#         type = types.str;
#         default = "";
#       };
#       token = mkOption {
#         type = types.str;
#         default = "";
#       };
#       caHash = mkOption {
#         type = types.str;
#         default = "";
#       };
#     };
#   };
#
#   config = mkIf cfg.enable (mkMerge [
#     {networking.firewall.enable = cfg.firewallOpen;}
#
#     ################ containerd ##############
#     (mkIf isWorker {
#       # services.containerd = {
#       #   enable = true;
#       #   package = containerdPkg;
#       #   settings.plugins."io.containerd.grpc.v1.cri".systemdCgroup = true;
#       # };
#     })
#
#     ################ master role #############
#     (mkIf isMaster {
#       # services.kubernetes = {
#       #   roles = ["master"];
#       #
#       #   kubelet.package = k8sPkgs.kubelet;
#       #   apiserver.package = k8sPkgs.kube-apiserver;
#       #   controllerManager.package = k8sPkgs.kube-controller-manager;
#       #   scheduler.package = k8sPkgs.kube-scheduler;
#       #
#       #   etcd = {
#       #     enable = true;
#       #     package = etcdPkg;
#       #   };
#       #
#       #   kubelet.extraOpts = ''
#       #     --container-runtime-endpoint=unix:///run/containerd/containerd.sock
#       #     ${cfg.extraKubeletOpts}
#       #   '';
#       #
#       #   kubeadm.extraConfig =
#       #     lib.recursiveUpdate
#       #     {
#       #       apiServer.extraArgs =
#       #         cfg.extraApiArgs // {"service-node-port-range" = cfg.nodePortRange;};
#       #     }
#       #     cfg.kubeadmExtra;
#       # };
#     })
#
#     ############### worker role ##############
#     (mkIf (isWorker && !isMaster) {
#       # services.kubernetes = {
#       #   roles = ["node"];
#       #   kubelet.package = k8sPkgs.kubelet;
#       #   kubelet.extraOpts = ''
#       #     --container-runtime-endpoint=unix:///run/containerd/containerd.sock
#       #     ${cfg.extraKubeletOpts}
#       #   '';
#       #   kubeadm.join = {
#       #     enable = true;
#       #     address = cfg.join.address;
#       #     token = cfg.join.token;
#       #     caCertHash = cfg.join.caHash;
#       #   };
#       # };
#
#       # services.containerd = {
#       #   enable = true;
#       #   package = containerdPkg;
#       #   settings.plugins."io.containerd.grpc.v1.cri".systemdCgroup = true;
#       # };
#     })
#
#     ######## build info for debugging ########
#     {
#       # environment.etc."k8s-build-info".text = ''
#       #   role=${cfg.role}
#       #   k8s=${k8sPkgs.kubelet.version}
#       #   etcd=${etcdPkg.version}
#       #   containerd=${containerdPkg.version}
#       # '';
#     }
#   ]);
# }
