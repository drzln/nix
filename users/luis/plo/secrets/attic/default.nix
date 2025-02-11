{ config, lib, ... }: {
  sops.secrets."attic/key" = {
    sopsFile = ../../../../../secrets.yaml;
    path = "/home/luis/.secrets/attic/key";
  };
  sops.secrets."attic/jwt/token" = {
    sopsFile = ../../../../../secrets.yaml;
    path = "/home/luis/.secrets/attic/jwt/token";
  };
}
