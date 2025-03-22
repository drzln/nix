[
  (self: super: {
    etcd = super.etcd.override {
      version = "3.5.15";
      # Possibly also override src = fetchFromGitHub { ... } if 3.5.15 is still in Nixpkgs
    };
  })

  # build qemu with hvf support
  (self: super: {
    qemu = super.qemu.overrideAttrs (old: {
      configureFlags =
        old.configureFlags
        ++ [
          "--enable-hvf"
          "--enable-cocoa"
          "--target-list=aarch64-softmmu"
        ];
    });
  })

  # (self: super: {
  #   neovim = super.callPackage ../packages/neovim {};
  # })
  (self: super: {
    cb = super.buildGoPackage {
      pname = "cb";
      version = "1.0.0";

      src = super.fetchFromGitHub {
        owner = "niedzielski";
        repo = "cb";
        rev = "main"; # Replace with the desired commit or tag
        sha256 = "sha256-OsHIacgorYnB/dPbzl1b6rYUzQdhTtsJYLsFLJxregk=";
      };

      goPackagePath = "github.com/niedzielski/cb";

      buildInputs = with super; [
        go
      ];
    };
  })
]
