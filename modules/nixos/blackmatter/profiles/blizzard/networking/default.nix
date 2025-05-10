# modules/nixos/blackmatter/profiles/blizzard/networking/default.nix
{...}: {
  networking.networkmanager.enable = true;
  networking.wireless.interfaces = ["wlp0s20f3"];
  # networking.firewall.enable = false;
  # networking.firewall.extraCommands = ''
  #   ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  # '';
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  services.dnsmasq.enable = true;
  services.dnsmasq.settings.server = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
}
