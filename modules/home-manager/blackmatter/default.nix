{lib, ...}:
with lib; {
  imports = [
    ./profiles
    ./components
  ];

  options = {
    blackmatter = {
      enable = mkEnableOption "enable blackmatter";
    };
  };
}
