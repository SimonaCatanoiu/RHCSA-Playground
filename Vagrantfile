VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
machines = YAML.load_file('./extras/machines.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  config.vm.define machines["bastion_vmname"] do |bastion|
      bastion.vm.box = "simonaesy/rhel9-arm"
      bastion.vm.box_version = "0.1.0"
      bastion.vm.hostname = machines["bastion_hostname"]
      bastion.vbguest.auto_update = false
      bastion.vm.network "private_network", ip: machines["bastion_ip"]
      bastion.vm.network "public_network", ip: machines["bastion_ip_pub"]
      bastion.vm.provision "shell", path: "./extras/initial-setup.sh"
      bastion.vm.provision "shell", path: "./extras/bastion-setup.sh"
      bastion.vm.synced_folder '.', '/vagrant', disabled: true
      bastion.vm.provider "vmware_fusion" do |v|
        v.vmx["displayName"] = machines["bastion_vmname"]
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end
  end

  config.vm.define machines["workstation_vmname"] do |workstation|
      workstation.vm.box = "simonaesy/rhel9-arm"
      workstation.vm.box_version = "0.1.0"
      workstation.vm.hostname = machines["workstation_hostname"]
      workstation.vm.network "private_network", ip: machines["workstation_ip"]
      class Foo < VagrantVbguest::Installers::RedHat
        def has_rel_repo?
          unless instance_variable_defined?(:@has_rel_repo)
            rel = release_version
            @has_rel_repo = communicate.test("dnf repolist")
          end
          @has_rel_repo
        end
    
        def install_kernel_devel(opts=nil, &block)
          cmd = "dnf update kernel -y"
          communicate.sudo(cmd, opts, &block)
    
          cmd = "dnf install -y kernel-devel"
          communicate.sudo(cmd, opts, &block)
    
          cmd = "shutdown -r now"
          communicate.sudo(cmd, opts, &block)
    
          begin
            sleep 5
          end until @vm.communicate.ready?
        end
      end

      workstation.vbguest.installer = Foo
      workstation.vm.provision "shell", path: "./extras/initial-setup.sh"
      workstation.vm.synced_folder '.', '/vagrant', disabled: true
      workstation.vm.synced_folder 'synced/', '/synced'
      workstation.vm.provision "shell", path: "./extras/workstation-setup.sh"
      workstation.vm.provider "vmware_fusion" do |v|
        v.vmx["displayName"] = machines["workstation_vmname"]
        v.vmx["memsize"] = "2048"
        v.vmx["numvcpus"] = "2"
        v.gui = true
      end
  end

  config.vm.define machines["servera_vmname"] do |servera|
      servera.vm.box = "simonaesy/rhel9-arm"
      servera.vm.box_version = "0.1.0"
      servera.vm.hostname = machines["servera_hostname"]
      servera.vbguest.auto_update = false
      servera.vm.network "private_network", ip: machines["servera_ip"]
      servera.vm.provision "shell", path: "./extras/initial-setup.sh"
      servera.vm.synced_folder '.', '/vagrant', disabled: true
      servera.vm.provider "vmware_fusion" do |v|
        v.vmx["displayName"] = machines["servera_vmname"]
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end
  end

  config.vm.define machines["serverb_vmname"] do |serverb|
      serverb.vm.box = "simonaesy/rhel9-arm"
      serverb.vm.box_version = "0.1.0"
      serverb.vm.hostname = machines["serverb_hostname"]
      serverb.vbguest.auto_update = false
      serverb.vm.network "private_network", ip: machines["serverb_ip"]
      serverb.vm.provision "shell", path: "./extras/initial-setup.sh"
      serverb.vm.synced_folder '.', '/vagrant', disabled: true
      serverb.vm.provider "vmware_fusion" do |v|
        v.vmx["displayName"] = machines["serverb_vmname"]
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end
  end
end