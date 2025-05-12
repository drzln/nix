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

  hardware.bluetooth.enable = false;
  services.printing.enable = false;
  services.avahi.enable = false;
  services.modemManager.enable = false;
  networking.networkmanager.enable = false;
  services.journald.storage = "volatile";
  services.journald.systemMaxUse = "100M";
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=10s
  '';
  systemd.network.waitOnline.enable = false;
  services.getty.autovts = 2;
  boot.initrd.compress = "lz4";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = ["06:00"];

  nix.extraOptions = ''
    min-free = 104857600
    max-free = 1073741824
  '';

  services.dnsmasq = {
    enable = true;
    settings = {
      port = 53;
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;
      neg-ttl = 3600;
      dns-forward-max = 250;
      no-poll = true;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      cache-size = 1000;
      log-queries = false;
      log-facility = "/dev/null";
    };
  };

  networking.useHostResolvConf = false;
  networking.nameservers = ["127.0.0.1"];
  services.resolvd.enable = false;
}
