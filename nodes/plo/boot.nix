{ ... }: {
  boot.kernel.sysctl = {
    "fs.file-max" = 2097152;
    "kernel.pid_max" = 4194304;
  };
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "selinux=0" 
    "apparmor=0"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
