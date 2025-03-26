# overlays/kubernetes-with-custom-etcd.nix
[
  (
    self: super: let
      version = "3.5.9";

      src = super.fetchFromGitHub {
        owner = "etcd-io";
        repo = "etcd";
        rev = "v${version}";
        sha256 = "sha256-Vp8U49fp0FowIuSSvbrMWjAKG2oDO1o0qO4izSnTR3U=";
      };

      etcdserver = super.buildGoModule {
        pname = "etcdserver";
        inherit version src;
        doCheck = false;
        vendorHash = "sha256-vu5VKHnDbvxSd8qpIFy0bA88IIXLaQ5S8dVUJEwnKJA=";
        modRoot = "./server";
        env = {CGO_ENABLED = "0";};
        postBuild = ''
          # Rename "server" to "etcd" if needed
          mv "$GOPATH"/bin/{server,etcd} || true
        '';
      };

      etcdctl = super.buildGoModule {
        pname = "etcdctl";
        inherit version src;
        doCheck = false;
        vendorHash = "sha256-awl/4kuOjspMVEwfANWK0oi3RId6ERsFkdluiRaaXlA=";
        modRoot = "./etcdctl";
        env = {CGO_ENABLED = "0";};
      };

      etcdutl = super.buildGoModule {
        pname = "etcdutl";
        inherit version src;
        doCheck = false;
        vendorHash = "sha256-i60rKCmbEXkdFOZk2dTbG5EtYKb5eCBSyMcsTtnvATs=";
        modRoot = "./etcdutl";
        env = {CGO_ENABLED = "0";};
      };

      # Combine everything into one package "etcd-3.5.9"
      etcd = super.symlinkJoin {
        name = "etcd-${version}";
        paths = [etcdserver etcdctl etcdutl];
        doCheck = false;
      };
    in {
      # 1) Override the top-level 'etcd' to be your custom build.
      inherit etcd;

      # 2) Override Kubernetes so that it uses your custom etcd
      #    instead of the default 'etcd3'.
      #    This ensures Kubernetes references pkgs.etcd -> your custom build.
      # kubernetes = super.kubernetes.override {
      #   etcd3 = etcd;
      # };

      # You can also export them by name if you like:
      # etcdserver = etcdserver;
      # etcdctl = etcdctl;
      # etcdutl = etcdutl;
    }
  )
]
