include_recipe "main::packages"
#create  project directory
directory node["project_directory"] do
  path node["project_directory"]
  owner node['user']['default']['username']
  group node['user']['default']['username']
  mode "0755"
  action :create
end

include_recipe "main::bash"
