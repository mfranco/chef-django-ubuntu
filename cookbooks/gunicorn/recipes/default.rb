include_recipe 'python'

gunicorn_install "gunicorn" do
  virtualenv node['python']['virtualenv']['path']
end

gunicorn_config "/etc/gunicorn/myapp.py" do
  path node["python"]["webapp"]["path"] << node["python"]["webapp"]["name"] << ".py"
  listen node["gunicorn"]["listen"]
  backlog node["gunicorn"]["backlog"]
  preload_app false
  worker_processes node["gunicorn"]["worker_processes"]
  worker_class node["gunicorn"]["worker_class"]
  worker_timeout node["gunicorn"]["worker_timeout"]
  worker_keepalive node["gunicorn"]["worker_keepalive"]
  owner node["gunicorn"]["owner"]
  group node["gunicorn"]["group"]
  pid node["gunicorn"]["pid"]
end
