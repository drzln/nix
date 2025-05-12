{
  modulesPath,
  config,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  hardware.nvidia.open = true;
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/19f6a7df-d334-466a-be69-328de346befd";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A77-20B1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };
  fileSystems."/var/lib" = {
    device = "/dev/disk/by-uuid/185105ce-2e61-4514-8de8-d67fec049deb";
    fsType = "xfs";
  };
  swapDevices = [
    {device = "/dev/disk/by-uuid/255bc5a7-978c-4606-a7ae-bcc20385e830";}
  ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
