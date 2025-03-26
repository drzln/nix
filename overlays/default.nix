[
  (
    self: super: let
      version = "3.5.9";

      # 1) Top-level fetch of the Etcd source tarball with an SRI "fake" placeholder.
      #    The 'sha256' attribute must be in "sha256-<base64>=" form, or Nix complains
      #    it doesn't know the type. This *will* fail on first build, printing the real hash.
      src = super.fetchFromGitHub {
        owner = "etcd-io";
        repo = "etcd";
        rev = "v${version}";
        # 64 A's as a base64 placeholder => "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        sha256 = "sha256-Vp8U49fp0FowIuSSvbrMWjAKG2oDO1o0qO4izSnTR3U=";
      };
    in rec {
      ###################################################################
      # etcdserver (server subdir)
      ###################################################################
      etcdserver = super.buildGoModule {
        pname = "etcdserver";
        inherit version src;
        doCheck = false;

        # Use a base64 SRI placeholder for 'vendorHash':
        vendorHash = "sha256-vu5VKHnDbvxSd8qpIFy0bA88IIXLaQ5S8dVUJEwnKJA=";

        modRoot = "./server";
        env = {CGO_ENABLED = "0";};

        postBuild = ''
          # If the submodule outputs a binary named "server", rename to "etcd"
          mv "$GOPATH"/bin/{server,etcd} || true
        '';
      };

      ###################################################################
      # etcdctl (CLI subdir)
      ###################################################################
      etcdctl = super.buildGoModule {
        pname = "etcdctl";
        inherit version src;
        doCheck = false;

        vendorHash = "sha256-awl/4kuOjspMVEwfANWK0oi3RId6ERsFkdluiRaaXlA=";

        modRoot = "./etcdctl";
        env = {CGO_ENABLED = "0";};
      };

      ###################################################################
      # etcdutl (utility subdir)
      ###################################################################
      etcdutl = super.buildGoModule {
        pname = "etcdutl";
        inherit version src;
        doCheck = false;

        vendorHash = "sha256-i60rKCmbEXkdFOZk2dTbG5EtYKb5eCBSyMcsTtnvATs=";

        modRoot = "./etcdutl";
        env = {CGO_ENABLED = "0";};
      };

      ###################################################################
      # Combine everything into 'etcd' using symlinkJoin
      ###################################################################
      etcd = super.symlinkJoin {
        name = "etcd-${version}";
        paths = [etcdserver etcdctl etcdutl];
        doCheck = false;
      };
    }
  )
]
