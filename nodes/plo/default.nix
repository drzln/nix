{ outputs, ... }:
{
  imports = [ 
    outputs.nixosModules.blackmatter 
    outputs.nixosModules.antimatter 
  ];
  blackmatter.host = "plo";
  blackmatter.dns.enable = true;
  blackmatter.sops.enable = true;
  blackmatter.boot.plo.enable = true;
  blackmatter.users.enable = true;
  blackmatter.fonts.enable = true;
  blackmatter.global.enable = true;
  blackmatter.xserver.enable = true;
  blackmatter.display.enable = true;
  blackmatter.pipewire.enable = true;
  blackmatter.services.enable = true;
  blackmatter.packages.enable = true;
  blackmatter.programs.enable = true;
  blackmatter.networking.enable = true;
  blackmatter.hardware.plo.enable = true;
  blackmatter.virtualization.enable = true;

  antimatter.services.consul.enable = true;
  antimatter.services.nomad.enable = true;
}
