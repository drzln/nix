[
  (self: super: {
    etcd = super.buildGoModule {
      pname = "etcd";
      version = "3.5.9";

      src = super.fetchFromGitHub {
        owner = "etcd-io";
        repo = "etcd";
        rev = "v3.5.9";
        sha256 = "0c7k38gns8019k3prihil21n14khz3lq2bzvd2i9qx23s4qsm4pi"; # Example - update as needed
      };

      modRoot = ".";
      subPackages = ["./server" "./etcdctl"];

      # If needed, set goModSha256 and vendorSha256:
      goModSha256 = null;
      vendorSha256 = null;

      # If you want to run the tests:
      # doCheck = true;

      # Extra build or install phases if needed, e.g.:
      # buildPhase = ...
      # installPhase = ...

      inherit (super.go) go;
    };
  })
]
