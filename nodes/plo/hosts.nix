{...}: {
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [
        "/router/192.168.50.1"
        "/rai/192.168.50.2"
      ];
    };
  };
}
