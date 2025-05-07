# users/luis/plo/secrets/kubernetes.nix
{...}: {
  sops.secrets = {
    "ca/crt" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.crt";
    };
    "ca/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.key";
    };
    "apiserver/crt" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.crt";
    };
    "apiserver/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.key";
    };
    "kubelet/crt" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.crt";
    };
    "kubelet/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.key";
    };
    "etcd/crt" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.crt";
    };
    "etcd/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.key";
    };
    "admin/crt" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.crt";
    };
    "admin/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.key";
    };
    "san/cnf" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/san.cnf";
    };
  };
}
