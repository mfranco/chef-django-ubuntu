template node['user']['default']['home_directory'] + 'bashrc' do
  source 'bash.erb'
  mode '644'
  owner node['user']['username']
  group node['user']['username']
end
