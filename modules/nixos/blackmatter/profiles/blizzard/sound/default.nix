# modules/nixos/blackmatter/profiles/blizzard/sound/default.nix
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = false;
    jack.enable = true;
  };
  services.pipewire.wireplumber.enable = true;
  services.pulseaudio.enable = false;
}
