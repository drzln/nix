# users/luis/plo/packages.nix
{pkgs, ...}: {
  home.packages = [
    (pkgs.stdenv.mkDerivation {
      pname = "connect-vpn-pinger";
      version = "1.0.0";

      src = pkgs.writeScript "connect-vpn-pinger.sh" ''
        #!/usr/bin/env bash
        sudo openconnect --protocol=gp --mtu=1200 pan.corp.pinger.com
      '';

      phases = ["installPhase"];

      installPhase = ''
        mkdir -p $out/bin
        install -m755 "$src" $out/bin/connect-vpn-pinger
      '';
    })
  ];
}
