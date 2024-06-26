require 'getoptlong'

# Parse CLI arguments.
opts = GetoptLong.new(
  [ '--provider', GetoptLong::OPTIONAL_ARGUMENT ],
)

provider = 'virtualbox'
begin
  opts.each do |opt, arg|
    case opt
    when '--provider'
      provider = arg
    end
  end
rescue
end

class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end

vms = {
  'kubemaster01' => {'memory' => '2048', 'cpus' => 2, 'ip' => '20'},
  'node01'       => {'memory' => '1280', 'cpus' => 1, 'ip' => '30'},
  'node02'       => {'memory' => '1280', 'cpus' => 1, 'ip' => '40'}
}

Vagrant.configure("2") do |config|
  vms.each do |name, conf|
    config.vm.define "#{name}" do |virtual|
      virtual.vm.box = "ubuntu/focal64"
      virtual.vm.hostname = "#{name}"
      
      # Configurações de rede privada e pública
      virtual.vm.network "private_network", ip: "192.168.16.#{conf['ip']}"
      
      # Provisionamento de arquivos e comandos shell
      virtual.vm.provision "file", source: "files/motd", destination: ".motd"
      virtual.vm.provision "file", source: "files", destination: "/home/vagrant/"
      virtual.vm.provision "shell", inline: "sudo cp ~vagrant/.motd /etc/motd"
      
      # Configuração do provider VirtualBox
      virtual.vm.provider "virtualbox" do |vb, override|
        vb.name = "#{name}"
        vb.memory = "#{conf['memory']}"
        vb.cpus = "#{conf['cpus']}"
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end
      
      # Configuração do provider Hyper-V
      virtual.vm.provider "hyperv" do |hv, override|
        hv.vmname = "#{name}"
        hv.memory = "#{conf['memory']}"
        hv.cpus = "#{conf['cpus']}"
      end
      
      # Provisionamento adicional
      virtual.vm.provision "shell", path: 'provision/ssh-keys.sh'
    end
  end
  
  config.vm.define "controller", primary: true do |controller|
    controller.vm.box = "ubuntu/focal64"
    controller.vm.hostname = "controller"
    
    # Configuração da rede privada e pública para o controlador
    controller.vm.network "private_network", ip: "192.168.16.10"
    
    # Provisionamento de arquivos e comandos shell
    controller.vm.provision "file", source: "files/motd", destination: ".motd"
    controller.vm.provision "file", source: "files", destination: "/home/vagrant/"
    controller.vm.provision "file", source: "configure-controller", destination: "/home/vagrant/"
    controller.vm.provision "shell", inline: "sudo cp ~vagrant/.motd /etc/motd; sudo apt-get -y install vim python3 git"
    
    # Configuração do provider VirtualBox
    controller.vm.provider "virtualbox" do |vb, override|
      vb.name = "controller"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    end
    
    # Configuração do provider Hyper-V
    controller.vm.provider "hyperv" do |hv, override|
      hv.vmname = "controller"
      hv.memory = "512"
      hv.cpus = 1
    end
    
    # Provisionamento adicional
    controller.vm.provision "shell", path: 'provision/ssh-keys.sh'
    controller.vm.provision "shell", path: 'provision/setup_k8s.sh'
    controller.vm.provision "shell", privileged: false, path: 'provision/configure_controller.sh'
    controller.vm.provision "shell", path: 'provision/running_sample.sh'
  end
end
