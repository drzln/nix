[
  (self: super: {
    sheldon = super.buildRustPackage rec {
      pname = "sheldon";
      version = "0.9.0";
      src = super.fetchFromGitHub {
        owner = "rossmacarthur";
        repo = "sheldon";
        rev = version;
        sha256 = "1ugalni0kbhf75vlv1pkk2u2ge8h8vmmllqs11voldurfjgu96s8";
      };
      cargoSha256 = super.lib.fakeSha256;
      nativeBuildInputs = [super.installShellFiles];
      buildInputs = [super.openssl super.curl] ++ super.lib.optionals super.stdenv.isDarwin [super.Security];
      doCheck = false;
    };
  })
]
