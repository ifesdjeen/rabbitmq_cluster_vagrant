node[:hostfile_entries].each do |(k,v)|
  hostsfile_entry k do
    hostname v
    action :remove
  end

  hostsfile_entry k do
    hostname v
    action :create_if_missing
  end
end
