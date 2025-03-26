[
  (
    self: super: let
      lib = super.lib;
      version = "3.5.9";

      # Fetch the main etcd source. Must use 'sha256', not 'hash'.
      src = super.fetchFromGitHub {
        owner = "etcd-io";
        repo = "etcd";
        rev = "v${version}";
        sha256 = "1cqhy33g42npshcrk7gm6j2fwmvxl8zjvb0qzjbrc6635fvlym5k";
      };

      meta = {
        description = "Distributed reliable key-value store (Etcd) ${version}";
        homepage = "https://etcd.io/";
      };
    in rec {
      ########################################################################
      # 1) etcdserver (main etcd binary, from 'server' subdirectory)
      ########################################################################
      etcdserver = super.buildGoModule {
        pname = "etcdserver";
        inherit version src meta;

        # 'vendorHash' is required instead of 'vendorSha256'.
        vendorHash = lib.fakeSha256; # Replace with the printed SRI from build logs

        # The 'modRoot' points to the 'server' folder's go.mod
        modRoot = "./server";

        # Recommended approach for CGO:
        env = {
          CGO_ENABLED = "0";
        };

        # Add optional ldflags if you prefer, e.g. version info:
        ldflagsArray = ["-X go.etcd.io/etcd/api/v3/version.GitSHA=GitNotFound"];

        # The submodule might produce a binary named 'server' => rename it to 'etcd'
        postBuild = ''
          mv "$GOPATH"/bin/{server,etcd}
        '';
      };

      ########################################################################
      # 2) etcdctl (CLI tool, from 'etcdctl' subdirectory)
      ########################################################################
      etcdctl = super.buildGoModule {
        pname = "etcdctl";
        inherit version src meta;

        vendorHash = lib.fakeSha256; # Replace with the printed SRI from build logs
        modRoot = "./etcdctl";

        env = {
          CGO_ENABLED = "0";
        };
      };

      ########################################################################
      # 3) etcdutl (utility tool, from 'etcdutl' subdirectory)
      ########################################################################
      etcdutl = super.buildGoModule {
        pname = "etcdutl";
        inherit version src meta;

        vendorHash = lib.fakeSha256; # Replace with the printed SRI from build logs
        modRoot = "./etcdutl";

        env = {
          CGO_ENABLED = "0";
        };
      };

      ########################################################################
      # 4) etcd - a single package that combines all binaries
      ########################################################################
      etcd = super.symlinkJoin {
        name = "etcd-${version}";
        inherit meta;
        paths = [
          etcdserver
          etcdctl
          etcdutl
        ];

        passthru = {
          inherit etcdserver etcdctl etcdutl;
        };
      };
    }
  )
]
