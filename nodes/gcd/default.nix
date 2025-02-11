{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ]; # Using the modesetting driver
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = false;

  boot.kernelParams = [
    "acpi_backlight=native" # Use native ACPI backlight interface
    "i915.force_probe=*" # Force i915 driver to recognize the GPU
    # "i915.enable_dpcd_backlight=1" # Optional: uncomment if needed
  ];

  boot.kernelModules = [ "i915" ]; # Ensure Intel graphics module is loaded

  boot.kernelPackages = pkgs.linuxPackages_latest; # Use the latest kernel packages

  services.xserver.xkb.options = "eurosign:e,ctrl:nocaps"; # Remap Caps Lock to Control

  nixpkgs.config.allowUnfree = true; # Enable unfree software

  nix.settings.experimental-features = [ 
		"nix-command"
		"flakes"
	];
  environment.systemPackages = with pkgs; [
    mesa
    mesa-demos
    vulkan-loader
    vulkan-tools
    intel-gpu-tools
    brightnessctl
    xorg.xrandr
    xorg.xev
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    setSocketVariable = true;
    enable = true;
  };
}
