[
  (self: super: {
    sheldon-special = super.rustPlatform.buildRustPackage rec {
      pname = "sheldon";
      version = "0.9.0";

      src = super.fetchFromGitHub {
        owner = "rossmacarthur";
        repo = "sheldon";
        rev = "v${version}";
        sha256 = "sha256-gy6AEBHk3rB1UdF+iqRWDA4DoEXQJ6Y+Ec4SaAZPrm4=";
      };

      cargoSha256 = "sha256-p+d5kOgfnlj4Z3+MgPbOjgEpKxmmXrOBOT+g9yObRw8=";

      nativeBuildInputs = [super.installShellFiles];
      buildInputs = with super;
        [
          openssl
          curl
        ]
        ++ lib.optionals stdenv.isDarwin [super.darwin.apple_sdk.frameworks.Security];

      meta = with super.lib; {
        description = "Fast, configurable Zsh plugin manager";
        homepage = "https://github.com/rossmacarthur/sheldon";
        license = licenses.mit;
      };
    };
  })
]
