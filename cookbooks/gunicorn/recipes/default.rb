include_recipe 'python'

gunicorn_install "gunicorn" do
  virtualenv node['python']['virtualenv']['path']
end

template node["project_directory"] + node["python"]["webapp"]["name"] + ".py" do
  source 'gunicorn.py.erb'
  mode '644'
  owner node['user']['default']['username']
  group node['user']['default']['username']
end

