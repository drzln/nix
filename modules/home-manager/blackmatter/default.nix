{lib, ...}:
with lib; {
  imports = [./profiles];
  options = {
    blackmatter = {
      enable = mkEnableOption "enable blackmatter";
    };
  };
}
