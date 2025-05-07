# users/luis/plo/secrets/kubernetes.nix
{...}: {
  sops.secrets = {
    "ca/cert" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/ca.crt";
    };
    "ca/key" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/ca.key";
    };
    "apiserver/cert" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.crt";
    };
    "apiserver/key" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.key";
    };
    "kubelet/cert" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.crt";
    };
    "kubelet/key" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.key";
    };
    "etcd/cert" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/etcd.crt";
    };
    "etcd/key" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/etcd.key";
    };
    "admin/cert" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/admin.crt";
    };
    "admin/key" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/admin.key";
    };
    "san/cnf" = {
      sopsFile = ../../../../kubernetes.yaml;
      path = "/var/lib/blackmatter/pki/san.cnf";
    };
  };
}
