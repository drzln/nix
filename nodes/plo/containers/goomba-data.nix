{...}: let
  data = rec {
    name = "attic";
    user = "luis";
    domain_prefix = "local.pleme.io";
    domain = "${name}.${domain_prefix}";
    uid = 1001;
    ssh-pub-key = ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyPrBmWSILSlqfgd7a4bPyDyzKTERfHEF+V0IQSiDZxcLSkE8+90lqYNh81c9xme09DUKAfd95obUKdcws5PI8NSoHbw70M3Ik2ZVkqGOQpGfcq7BeIDvtqkZyKjCmrCZlEb6RmFVCfso0Xts3/FdxeD3y6BMvGY/oRDLOrwPzGlX+hHAjE4jxG+tGAMWaI3KoAkwU3kfnnDxrp0swJ5Ns3vlR0yihci8SdMECA4fdPUpwzy0uaIpKXruiB44OdW/rxEyM1MujeBVaLeygtKjtYBvC1CZ7ofia1bHDJ2qzmlsDckmIAgVTH6BrcSw3ZOmmG6tx2H5yl/Tchmq72YeBP647fGVsVwLqf3wIPeoR8qcrYTE51/R/URXYlOMsuyYg+2WJrUKXO8pX/n60YDD0BR26VW/d3yjkDH+csWspmAcqN7vPIu8hIMjK0p8EryP/G7yy985kjETkNuyQPX19pGnEMJEBzFlm8XE+HzdxFm06gi/i8y1XC/TBk/IIWk= luis@plo'';
  };
in
  data
