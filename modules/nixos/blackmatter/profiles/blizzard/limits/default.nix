{...}:{
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "soft";
      item = "stack";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "stack";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "soft";
      item = "rss";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "rss";
      value = "unlimited";
    }
  ];
}
