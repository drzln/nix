{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cri-tools
    kubernetes-helm
  ];
}
