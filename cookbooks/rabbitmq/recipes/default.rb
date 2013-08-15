#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2009, Benjamin Black
# Copyright 2009-2013, Opscode, Inc.
# Copyright 2012, Kevin Nuckolls <kevin.nuckolls@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'erlang'

case node['platform_family']
when 'debian'
  # installs the required setsid command -- should be there by default but just in case
  package 'util-linux'

  if node['rabbitmq']['use_distro_version']

    package 'rabbitmq-server'

  else

    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb" do
      source node['rabbitmq']['package']
      action :create_if_missing
    end

    dpkg_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"

  end

when 'rhel', 'fedora'

  if node['rabbitmq']['use_distro_version'] then

    package 'rabbitmq-server'

  else

    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm" do
      source node['rabbitmq']['package']
      action :create_if_missing
    end

    rpm_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm"

  end

when 'smartos'

  package 'rabbitmq'

  service 'epmd' do
    action :start
  end

  service node['rabbitmq']['service_name'] do
    action :start
  end

end

directory node['rabbitmq']['mnesiadir'] do
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '775'
  recursive true
end

## You'll see setsid used in all the init statements in this cookbook. This
## is because there is a problem with the stock init script in the RabbitMQ
## debian package (at least in 2.8.2) that makes it not daemonize properly
## when called from chef. The setsid command forces the subprocess into a state
## where it can daemonize properly. -Kevin (thanks to Daniel DeLeo for the help)
service node['rabbitmq']['service_name'] do
  start_command 'sudo setsid /etc/init.d/rabbitmq-server start'
  stop_command 'sudo setsid /etc/init.d/rabbitmq-server stop ; sudo killall epmd ; sudo killall beam ; sudo killall rabbitmq-server'
  restart_command 'sudo setsid /etc/init.d/rabbitmq-server stop ; sudo killall epmd ; sudo killall beam ; sudo killall rabbitmq-server ; setsid /etc/init.d/rabbitmq-server start'
  status_command 'sudo setsid /etc/init.d/rabbitmq-server status'
  supports :status => true, :restart => true
  action [ :enable, :start ]
  not_if { platform?('smartos') }
end

template "#{node['rabbitmq']['config_root']}/rabbitmq-env.conf" do
  source 'rabbitmq-env.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

template "#{node['rabbitmq']['config_root']}/rabbitmq.config" do
  source 'rabbitmq.config.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

if File.exists?(node['rabbitmq']['erlang_cookie_path'])
  existing_erlang_key =  File.read(node['rabbitmq']['erlang_cookie_path'])
else
  existing_erlang_key = ''
end

if node['rabbitmq']['cluster'] && (node['rabbitmq']['erlang_cookie'] != existing_erlang_key)
  # service "stop #{node['rabbitmq']['service_name']}" do
  #   service_name node['rabbitmq']['service_name']
  #   pattern node['rabbitmq']['service_name']
  #   action :stop
  # end

  log "stopping service[#{node['rabbitmq']['service_name']}] to change erlang_cookie" do
    level :info
    notifies :stop, "service[#{node['rabbitmq']['service_name']}]", :immediately
  end

  template node['rabbitmq']['erlang_cookie_path'] do
    source 'doterlang.cookie.erb'
    owner 'rabbitmq'
    group 'rabbitmq'
    mode 00400
    # notifies :start, "service[#{node['rabbitmq']['service_name']}]", :immediately
    notifies :run, "execute[restart-node]", :immediately
    notifies :run, "execute[reset-node]", :immediately
  end

  execute "restart-node" do
    command 'sudo setsid /etc/init.d/rabbitmq-server stop ; sudo killall epmd ; sudo killall beam ; sudo killall rabbitmq-server ; setsid /etc/init.d/rabbitmq-server start'
    action :nothing
  end

  # Need to reset for clustering #
  execute "reset-node" do
    command "rabbitmqctl stop_app && rabbitmqctl reset && rabbitmqctl start_app"
    action :nothing
  end
end
