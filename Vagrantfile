# -*- mode: ruby -*-

Vagrant::Config.run do |m|
  [1,2,3].each do |i|
    m.vm.define "rabbitmq_node_#{i}" do |rabbit_node|
      rabbit_node.vm.box = "precise64"
      rabbit_node.vm.customize ["modifyvm", :id,
                        "--memory", 1024,
                        "--cpus",     "1"]

      rabbit_node.vm.network :hostonly, "192.168.60.#{i}"
      rabbit_node.vm.forward_port 15672, 15672
      #rabbit_node.vm.hostname "node0#{i}"
      rabbit_node.vm.provision :shell, :inline => "sudo apt-get update --fix-missing"
      rabbit_node.vm.provision :shell, :inline => "sudo apt-get -y install zip"
      rabbit_node.vm.provision :shell, :inline => "sudo apt-get -y install emacs23-nox"
      rabbit_node.vm.provision :shell, :inline => "sudo apt-get -y install python-software-properties"
      rabbit_node.vm.provision :shell, :inline => "sudo mkdir -p /var/chef/cache"
      rabbit_node.vm.provision :shell, :inline => "sudo sh -c \"echo 'node0#{i}' > /etc/hostname\""
      rabbit_node.vm.provision :shell, :inline => "sudo hostname -F /etc/hostname"

      rabbit_node.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = ["./cookbooks"]

        chef.add_recipe "apt"
        chef.add_recipe "hostsfile::rabbit"
        chef.add_recipe "rabbitmq::mgmt_console"

        chef.json = {
          :hostfile_entries => {"192.168.60.1" => "rabbit",
            "192.168.60.1" => "node01",
            "192.168.60.2" => "node02",
            "192.168.60.3" => "node03"},
          :rabbitmq => {
            :nodename => "node0#{i}",
            :address => "192.168.60.#{i}",
            :erlang_cookie => "cookbook-cookie",
            :virtualhosts => ["test1", "test2", "test3"],
            :enabled_plugins => ["rabbitmq_management", "rabbitmq_management_visualiser"],
            :version => "3.1.4",
            :cluster => true,
            :cluster_disk_nodes => ['node01@node01', 'node02@node02']
          }
        }
      end
    end
  end
end
