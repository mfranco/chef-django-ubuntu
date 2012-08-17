template '/etc/supervisord.conf' do
  source 'supervisord.conf.erb'
  mode '644'
end
