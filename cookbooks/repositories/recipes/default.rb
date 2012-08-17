execute 'copy SSH public key' do
  command 'cp ' + node['user']['default']['home_directory'] + '.ssh/id_rsa.pub /root/.ssh/'
  action :run
end

execute 'copy SSH private key' do
  command 'cp ' + node['user']['default']['home_directory'] + '.ssh/id_rsa /root/.ssh/'
  action :run
end

include_recipe "repositories::git"
