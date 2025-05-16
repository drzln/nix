# nodes/common/kubernetes/secrets.nix
{...}: {
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets = {
    "cluster/token" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.token";
    };
  };
}
