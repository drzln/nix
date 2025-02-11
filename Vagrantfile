Vagrant.configure("2") do |config|

  # Use a suitable NixOS base. VM built with nixbox are tested to work with
  # this plugin.
  config.vm.box = "zimbatm/nixos-15.09-x86_64"

  # set hostname
  config.vm.hostname = "nixy"

  # Setup networking
  config.vm.network "private_network", ip: "172.16.16.16"

  # Add the htop package
  config.vm.provision :nixos,
    run: 'always',
    expression: {
      environment: {
        systemPackages: [ :htop ]
      }
    }

end
