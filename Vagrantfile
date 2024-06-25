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

vms = {
  'kubemaster01' => {'memory' => '3072', 'cpus' => 2},
  'node01'       => {'memory' => '1024', 'cpus' => 1},
  'node02'       => {'memory' => '1024', 'cpus' => 1}
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

      # Configurar a rede em modo bridge
      virtual.vm.network "public_network"

      virtual.vm.provision "file", source: "files/motd", destination: ".motd"
      virtual.vm.provision "file", source: "files", destination: "/home/vagrant/"
      virtual.vm.provision "shell", inline: "sudo cp ~vagrant/.motd /etc/motd"
      virtual.vm.boot_timeout = 900

      virtual.vm.provider provider.to_sym do |vb, override|
        vb.name = "#{name}"
        vb.memory = "#{conf['memory']}"
        vb.cpus = "#{conf['cpus']}"
      end

      virtual.vm.provision "shell", path: 'provision/ssh-keys.sh'
      virtual.vm.provision "shell", path: 'provision/install_k8s.sh'
    end
  end

  config.vm.define "controller", primary: true do |controller|
    controller.vm.box = "ubuntu/focal64"
    controller.vm.hostname = "controller"

    # Configurar a rede em modo bridge
    controller.vm.network "public_network"

    controller.vm.boot_timeout = 900

    controller.vm.provision "file", source: "files/motd", destination: ".motd"
    controller.vm.provision "file", source: "files", destination: "/home/vagrant/"
    controller.vm.provision "file", source: "configure-controller", destination: "/home/vagrant/"
    controller.vm.provision "shell", path: 'provision/install_k8s.sh'

    controller.vm.provider provider.to_sym do |vb, override|
      vb.name = "controller"
      vb.memory = "2048"
      vb.cpus = 2
    end

    controller.vm.provision "shell", path: 'provision/ssh-keys.sh'
    controller.vm.provision "shell", path: 'provision/prepare-ansible.sh'
    controller.vm.provision "shell", path: 'provision/configure_controller.sh'
    controller.vm.provision "shell", path: 'provision/running_sample.sh'
  end
end
