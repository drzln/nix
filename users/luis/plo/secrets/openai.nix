{...}: {
  sops.secrets."openai/pinger/token" = {
    sopsFile = ../../../../secrets.yaml;
    path = "/home/luis/.config/openai/pinger/token";
  };
}
