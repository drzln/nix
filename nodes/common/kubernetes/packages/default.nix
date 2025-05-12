{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    crictl
  ];
}
