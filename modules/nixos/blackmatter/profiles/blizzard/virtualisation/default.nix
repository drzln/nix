{ ... }: {
  virtualisation.libvirtd.enable = false;
  virtualisation.podman.enable = false;
  virtualisation.podman.dockerSocket.enable = false;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = false;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    setSocketVariable = false;
    enable = false;
  };
}
