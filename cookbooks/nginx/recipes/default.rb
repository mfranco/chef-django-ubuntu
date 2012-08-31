nginx_prefix = node['nginx']['source']['prefix'] + node['nginx']['version']

conf_path = node['nginx']['dir'] + '/nginx.conf'

configure_flags = ["--prefix=" + nginx_prefix,
                   "--conf-path=" + conf_path,
                   "--sbin-path=" + node['nginx']['binary'],
                   "--pid-path=" + node['nginx']['pid_path'] + node['nginx']['pid_file'],
                   "--user=" + node['nginx']['user'],
                   "--error-log-path=" + node["nginx"]["log_dir"] + "/error.log",
                   "--http-log-path=" + node["nginx"]["log_dir"] + "/access.log",
                   "--with-http_ssl_module",
                   "--with-http_gzip_static_module"
                  ].join(" ")

puts configure_flags

src_filepath =  Chef::Config['file_cache_path'] + '/nginx-' + node['nginx']['version'] + ".tar.gz"

remote_file node['nginx']['source']['url'] do
  source node['nginx']['source']['url']
  path src_filepath
  backup false
end

user node['nginx']['user'] do
  system true
  shell "/bin/false"
  home "/var/www"
end



node['nginx']['source']['modules'].each do |ngx_module|
  include_recipe "nginx::#{ngx_module}"
end



bash "compile_nginx_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
cd nginx-#{node['nginx']['version']}
make clean

./configure #{configure_flags}

make && make install

rm -f #{node['nginx']['dir']}/nginx.conf
EOH
  creates node['nginx']['binary']
  notifies :restart, "service[nginx]"
end



template "/etc/init.d/nginx" do
    source "nginx.init.erb"
    owner "root"
    group "root"
    mode "0755"
end

service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action :enable
end


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
  notifies :reload, resources(:service => "nginx"), :immediately
end
