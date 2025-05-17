{...}: {
  imports = [
    ./secrets.nix
  ];
  blackmatter.components.kubernetes = {
    enable = true;
    role = "single";
    fluxcd.enable = true;
    fluxcd.owner = "drzzln";
    fluxcd.repo = "kube-clusters";
    fluxcd.branch = "main";
    fluxcd.path = "clusters/rai";
    fluxcd.patFile = "/run/secrets/kubernetes/fluxcd/pat";
    fluxcd.runAtBoot = false;
    fluxcd.lockFile = "/var/lib/blackmatter/fluxcd-bootstrap.lock";
  };
}
