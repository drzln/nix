# { lib, ... }: {
#   dconf.settings = {
#     "org/gnome/desktop/screensaver" = {
#       lock-delay = lib.hm.gvariant.mkUint32 10000;
#     };
#   };
# }
