# nodes/plo/secrets.nix
{...}: {
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets = {
    "kubernetes/configs/scheduler/kubeconfig" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/scheduler.kubeconfig";
    };
    "kubernetes/configs/admin/kubeconfig" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/admin.kubeconfig";
    };
    "kubernetes/configs/kubelet/config" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.config";
    };
    "kubernetes/configs/kubelet/kubeconfig" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/kubelet.kubeconfig";
    };
    "kubernetes/configs/controller-manager/kubeconfig" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/controller-manager.kubeconfig";
    };
    "kubernetes/configs/bootstrap/node-rbac" = {
      mode = "0444";
      owner = "root";
      group = "root";
      sopsFile = ../../secrets.yaml;
      path = "/var/lib/blackmatter/pki/node-rbac.yaml";
    };
    # "kubernetes/ca/crt" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/ca.crt";
    # };
    # "kubernetes/ca/key" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/ca.key";
    # };
    # "kubernetes/apiserver/crt" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/apiserver.crt";
    # };
    # "kubernetes/apiserver/key" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/apiserver.key";
    # };
    # "kubernetes/kubelet/crt" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/kubelet.crt";
    # };
    # "kubernetes/kubelet/key" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/kubelet.key";
    # };
    # "kubernetes/etcd/crt" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/etcd.crt";
    # };
    # "kubernetes/etcd/key" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/etcd.key";
    # };
    # "kubernetes/admin/crt" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/admin.crt";
    # };
    # "kubernetes/admin/key" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/admin.key";
    # };
    # "kubernetes/san/cnf" = {
    #   mode = "0444";
    #   owner = "root";
    #   group = "root";
    #   sopsFile = ../../secrets.yaml;
    #   path = "/var/lib/blackmatter/pki/san.cnf";
    # };
  };
}
