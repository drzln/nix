{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cri-tools
    kubectl
    kubernetes-helm
  ];
}
