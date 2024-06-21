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
  'kubemaster01' => {'memory' => '1024', 'cpus' => 1},
  'node01'       => {'memory' => '512', 'cpus' => 1},
  'node02'       => {'memory' => '512', 'cpus' => 1}
}

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
  end

  config.vm.boot_timeout = 900

  vms.each do |name, conf|
    config.vm.define "#{name}" do |virtual|
      virtual.vm.box = "generic/alpine312"
      virtual.vm.hostname = "#{name}"

      # Remover todas as interfaces de rede NAT
      virtual.vm.networks.clear

      # Configurar a interface de rede no modo bridge
      virtual.vm.network "public_network", bridge: "Realtek Gaming GbE Family Controller", use_dhcp_assigned_default_route: true

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
      virtual.vm.provision "shell", inline: "sudo ip link set eth0 up"

      # Configurações adicionais de provisionamento
      virtual.vm.provision "shell", path: 'provision/ssh-keys.sh'
    end
  end

  # Configuração do controlador
  config.vm.define "controller", primary: true do |controller|
    controller.vm.box = "generic/alpine312"
    controller.vm.hostname = "controller"

    # Remover todas as interfaces de rede NAT
    controller.vm.networks.clear

    # Configurar a interface de rede no modo bridge
    controller.vm.network "public_network", bridge: "Realtek Gaming GbE Family Controller", use_dhcp_assigned_default_route: true

    controller.vm.boot_timeout = 900

    # Configurações de provisionamento para o controlador
    controller.vm.provision "file", source: "files/motd", destination: ".motd"
    controller.vm.provision "file", source: "files", destination: "/home/vagrant/"
    controller.vm.provision "file", source: "configure-controller", destination: "/home/vagrant/"
    controller.vm.provision "shell", inline: "sudo cp ~vagrant/.motd /etc/motd; sudo apk update; sudo apk add vim python3 git"

    controller.vm.provider provider.to_sym do |vb, override|
      vb.name = "controller"
      vb.memory = "512"
      vb.cpus = 1

      # Habilitar modo promíscuo para todas as interfaces de rede
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    end

    # Ativar a interface de rede dentro da VM
    controller.vm.provision "shell", inline: "sudo ip link set eth0 up"

    # Mais configurações de provisionamento para o controlador
    controller.vm.provision "shell", path: 'provision/ssh-keys.sh'
    controller.vm.provision "shell", path: 'provision/prepare-ansible.sh'
    controller.vm.provision "shell", path: 'provision/install_k8s.sh'
    controller.vm.provision "shell", privileged: "false", path: 'provision/configure_controller.sh'
    controller.vm.provision "shell", path: 'provision/running_sample.sh'
  end
end