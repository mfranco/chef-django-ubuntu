template node['user']['default']['home_directory'] + 'bashrc' do
  source 'bash.erb'
  mode '644'
  owner node['user']['default']['username']
  group node['user']['default']['username']
end
