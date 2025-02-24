{lib, ...}: {
  home.activation.aws-config-pre-reqs = lib.mkBefore ''
    [ ! -f ~/.aws/credentials ] && touch ~/.aws/credentials
  '';
  sops.secrets."aws/config" = {
    sopsFile = ../../../../secrets.yaml;
    path = "/home/luis/.aws/config";
  };
}
