# users/luis/plo/secrets/kubernetes.nix
{...}: {
  sops.secrets = {
    "ca/cert" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.crt";
    };
    "ca/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/ca.key";
    };
    "apiserver/cert" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.crt";
    };
    "apiserver/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/apiserver.key";
    };
    "kubelet/cert" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.crt";
    };
    "kubelet/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.key";
    };
    "etcd/cert" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.crt";
    };
    "etcd/key" = {
      sopsFile = ../../../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/etcd.key";
    };
    "admin/cert" = {
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
