{...}: {
  nix = {
    settings.trusted-users = ["ldesiqueira"]; # Replace with your macOS username
    linux-builder.enable = true;
  };
}
