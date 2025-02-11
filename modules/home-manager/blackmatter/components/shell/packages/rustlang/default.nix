pkgs:
with pkgs;
let
  OurRustc = pkgs.rustc.overrideAttrs (oldAttrs: rec {
    version = "1.71.0";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # Placeholder hash
    url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
  });
in
[
  cargo-edit
  rust-code-analysis
  rust-analyzer
  rust-script
  rustic-rs
  rust-motd
  rusty-man
  rustscan
  rustfmt
  rustcat
  rustc
  # OurRustc
]
