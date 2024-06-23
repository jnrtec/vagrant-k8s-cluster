require 'getoptlong'

# Parse CLI arguments.
opts = GetoptLong.new(
  [ '--provider', GetoptLong::OPTIONAL_ARGUMENT ],
)

provider='virtualbox'
begin
  opts.each do |opt, arg|
    case opt
    when '--provider'
      provider=arg
    end # case
  end # each
rescue
end

vms = {
  'kubemaster01' => {'memory' => '2048', 'cpus' => 3},
  'node01'       => {'memory' => '1280', 'cpus' => 1},
  'node02'       => {'memory' => '1280', 'cpus' => 1}
}

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
  end

  config.vm.boot_timeout = 900

  vms.each do |name, conf|
    config.vm.define "#{name}" do |virtual|
      virtual.vm.box = "ubuntu/focal64"
      virtual.vm.hostname = "#{name}"

      # Remover todas as interfaces de rede NAT
      virtual.vm.networks.clear

      # Configurar a interface de rede no modo bridge
      virtual.vm.network "public_network", bridge: "enp0s3", use_dhcp_assigned_default_route: true

      # Configurações de provisionamento
      virtual.vm.provision "file", source: "files/motd", destination: ".motd"
      virtual.vm.provision "file", source: "files", destination: "/home/vagrant/"
      virtual.vm.provision "shell", inline: "sudo cp ~vagrant/.motd /etc/motd"
      virtual.vm.boot_timeout = 900

      virtual.vm.provider provider.to_sym do |vb, override|
        vb.name = "#{name}"
        vb.memory = "#{conf['memory']}"
        vb.cpus = "#{conf['cpus']}"

        # Habilitar modo promíscuo para todas as interfaces de rede
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end

      # Ativar a interface de rede dentro da VM
      virtual.vm.provision "shell", inline: "sudo ip link set enp0s3 up"

      # Configurações adicionais de provisionamento
      virtual.vm.provision "shell", path: 'provision/ssh-keys.sh'
    end
  end

  # Configuração do controlador
  config.vm.define "controller", primary: true do |controller|
    controller.vm.box = "ubuntu/focal64"
    controller.vm.hostname = "controller"

    # Remover todas as interfaces de rede NAT
    controller.vm.networks.clear

    # Configurar a interface de rede no modo bridge
    controller.vm.network "public_network", bridge: "enp0s3", use_dhcp_assigned_default_route: true

    controller.vm.boot_timeout = 900

    # Configurações de provisionamento para o controlador
    controller.vm.provision "file", source: "files/motd", destination: ".motd"
    controller.vm.provision "file", source: "files", destination: "/home/vagrant/"
    controller.vm.provision "file", source: "configure-controller", destination: "/home/vagrant/"
    controller.vm.provision "shell", inline: <<-SHELL
      sudo cp ~vagrant/.motd /etc/motd
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl
      sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
      echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubelet kubeadm kubectl
      sudo apt-mark hold kubelet kubeadm kubectl
      sudo apt-get install -y docker.io
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo usermod -aG docker vagrant
      sudo apt-get install -y python3 python3-pip
      sudo pip3 install ansible
    SHELL

    controller.vm.provider provider.to_sym do |vb, override|
      vb.name = "controller"
      vb.memory = "512"
      vb.cpus = 1

      # Habilitar modo promíscuo para todas as interfaces de rede
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    end

    # Ativar a interface de rede dentro da VM
    controller.vm.provision "shell", inline: "sudo ip link set enp0s3 up"

    # Mais configurações de provisionamento para o controlador
    controller.vm.provision "shell", path: 'provision/ssh-keys.sh'
    controller.vm.provision "shell", path: 'provision/prepare-ansible.sh'
    controller.vm.provision "shell", path: 'provision/install_k8s.sh'
    controller.vm.provision "shell", privileged: "false", path: 'provision/configure_controller.sh'
    controller.vm.provision "shell", path: 'provision/running_sample.sh'
  end
end
