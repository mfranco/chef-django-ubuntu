unless(node['nginx']['source']['url'])
  node.set['nginx']['source']['url'] = "http://www.nginx.org/download/nginx-1.2.3.tar.gz"
end

nginx_url = node['nginx']['source']['url']

unless(node['nginx']['source']['prefix'])
  node.set['nginx']['source']['prefix'] = "/opt/nginx-#{node['nginx']['version']}"
end

nginx_prefix = node['nginx']['source']['prefix']

unless(node['nginx']['source']['conf_path'])
  node.set['nginx']['source']['conf_path'] = "#{node['nginx']['dir']}/nginx.conf"
end

conf_path = node['nginx']['source']['conf_path']

unless(node['nginx']['source']['default_configure_flags'])
  node.set['nginx']['source']['default_configure_flags'] = [
    "--prefix=#{node['nginx']['source']['prefix']}",
    "--conf-path=#{node['nginx']['dir']}/nginx.conf"
  ]
end

node.set['nginx']['binary'] = "#{node['nginx']['source']['prefix']}/sbin/nginx"

node.set['nginx']['daemon_disable'] = true
src_filepath = "#{Chef::Config['file_cache_path'] || '/tmp'}/nginx-#{node['nginx']['version']}.tar.gz"

remote_file nginx_url do
  source nginx_url
  path src_filepath
  backup false
end

user node['nginx']['user'] do
  system true
  shell "/bin/false"
  home "/var/www"
end

node.run_state['nginx_force_recompile'] = false
node.run_state['nginx_configure_flags'] = node['nginx']['source']['default_configure_flags']


node['nginx']['source']['modules'].each do |ngx_module|
  include_recipe "nginx::#{ngx_module}"
end

configure_flags = node.run_state['nginx_configure_flags']
nginx_force_recompile = node.run_state['nginx_force_recompile']


bash "compile_nginx_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
cd nginx-#{node['nginx']['version']} && make clean && ./configure #{node.run_state['nginx_configure_flags'].join(" ")}
make && make install
rm -f #{node['nginx']['dir']}/nginx.conf
EOH
end

node.run_state.delete(:nginx_configure_flags)
node.run_state.delete(:nginx_force_recompile)

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

include_recipe 'nginx::nginx_commons'

cookbook_file "#{node['nginx']['dir']}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
end
