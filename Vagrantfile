Vagrant.configure("2") do |config|
    config.vm.box = "debian/stretch64"
    config.vm.hostname = "project-v-vm"
    config.vm.network :private_network, ip: "192.168.0.42"
  
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", 4048]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        v.name = "project-v-vagrant"
    end
    
    config.vm.provision "shell", inline: <<-SHELL
      # Install dependencies
      echo "=====> Installing dependencies..."
      sudo apt update
      sudo apt-get dist-upgrade -y
      sudo apt-get install -y autoconf-archive curl bison g++ xz-utils libtool automake pkg-config perl libtool m4 autoconf gawk build-essential texinfo tree git sudo p7zip lzma-dev lzma wget coreutils -y && apt-get autoremove

      # Update dash symlink
      sudo cd /bin/ && sudo rm sh && sudo ln -s bash sh

      # Cloneing repo
      echo "=====> Cloneing repo..."
      git clone https://github.com/junland/project-v

      echo "=====> Project-V VM should be good to go. Have fun!"
    SHELL

  end
  
