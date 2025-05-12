{pkgs, ...}: {
  # use a real-time linux kernel
  boot.kernelPackages = pkgs.linuxPackages_rt;

  # Ensure CPU governor is "performance" for max speed
  powerManagement.cpuFreqGovernor = "performance";
  # (If using intel_pstate, this ensures CPU stays in performance mode)

  # Udev rule to set I/O scheduler for NVMe
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme0n1", ATTR{queue/scheduler}="none"
  '';

  # stop nvme drives from sleeping
  boot.kernelParams = ["nvme_core.default_ps_max_latency_us=0"];

  # balance interrupts across cpus
  services.irqbalance.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "fs.inotify.max_user_watches" = 524288;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  boot.loader.timeout = 1;
  boot.loader.grub.default = "saved";
  boot.loader.configurationLimit = 100;
}
