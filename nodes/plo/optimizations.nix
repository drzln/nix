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
}
