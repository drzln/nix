{ requirements, pkgs, ... }: {
  imports = [
    requirements.outputs.homeManagerModules.blackmatter
  ];
  blackmatter.enable = true;

  blackmatter.profiles.winter.enable = false;
  blackmatter.profiles.blizzard.enable = true;

  blackmatter.components.desktop.i3.monitors = {
    main = {
      name = "DP-2";
      mode = "1920x1080";
      rate = "360";
    };
  };

  blackmatter.components.gitconfig.enable = true;
  blackmatter.components.gitconfig.email = "luis@pleme.io";
  blackmatter.components.gitconfig.user = "luis";
}
