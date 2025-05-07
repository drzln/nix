# nodes/plo/secrets.nix
{...}: {
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets = {
    "kubernetes/ca/crt" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.crt";
    };
    "kubernetes/ca/key" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.key";
    };
    "kubernetes/apiserver/crt" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.crt";
    };
    "kubernetes/apiserver/key" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.key";
    };
    "kubernetes/kubelet/crt" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.crt";
    };
    "kubernetes/kubelet/key" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.key";
    };
    "kubernetes/etcd/crt" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.crt";
    };
    "kubernetes/etcd/key" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.key";
    };
    "kubernetes/admin/crt" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.crt";
    };
    "kubernetes/admin/key" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.key";
    };
    "kubernetes/san/cnf" = {
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/san.cnf";
    };
  };
}
