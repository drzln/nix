{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_rt;
}
