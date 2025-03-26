[
  (self: super: let
    lib = super.lib;
    version = "3.5.9";
    src = super.fetchFromGitHub {
      owner = "etcd-io";
      repo = "etcd";
      rev = "v${version}";
      # Replace this hash with the correct SRI hash for the source tarball, e.g. "sha256-..."
      hash = lib.fakeSha256;
    };

    # Common build settings for all subpackages
    CGO_ENABLED = 0;
    ldflags = ["-X go.etcd.io/etcd/api/v3/version.GitSHA=GitNotFound"];
    meta = {
      description = "Distributed reliable key-value store (Etcd) ${version}";
      homepage = "https://etcd.io/";
      maintainers = []; # fill in if needed
    };
  in {
    # Etcd server (main etcd binary)
    etcdserver = super.buildGoModule {
      pname = "etcdserver";
      inherit version src CGO_ENABLED ldflags meta;
      # Use the new 'vendorHash' instead of 'vendorSha256'
      vendorHash = lib.fakeSha256; # build once to see the correct hash, then replace

      modRoot = "./server";
      postBuild = ''
        # The server submodule may produce a binary named "server"
        # Rename it to "etcd" for consistency.
        mv "$GOPATH"/bin/{server,etcd}
      '';
    };

    # Etcdctl (command-line client)
    etcdctl = super.buildGoModule {
      pname = "etcdctl";
      inherit version src CGO_ENABLED meta;
      vendorHash = lib.fakeSha256; # replace with real hash
      modRoot = "./etcdctl";
    };

    # Etcdutl (utility tool)
    etcdutl = super.buildGoModule {
      pname = "etcdutl";
      inherit version src CGO_ENABLED meta;
      vendorHash = lib.fakeSha256; # replace with real hash
      modRoot = "./etcdutl";
    };

    # A combined package that symlinks all binaries into a single output
    etcd = super.symlinkJoin {
      name = "etcd-${version}";
      inherit meta;
      paths = [self.etcdserver self.etcdctl self.etcdutl];
      passthru = {
        inherit (self) etcdserver etcdctl etcdutl;
      };
    };
  })
]
