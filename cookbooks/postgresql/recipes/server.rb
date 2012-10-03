package 'postgresql'
package 'postgresql-client'


pg_dir = "/etc/postgresql/" + node['postgresql']['version'] + "/main"

service "postgresql" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
end

template  pg_dir + '/postgresql.conf' do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, resources(:service => "postgresql"), :immediately
end


template pg_dir + "/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql"), :immediately
end



# Default PostgreSQL install has 'ident' checking on unix user 'postgres'
# and 'md5' password checking with connections from 'localhost'. This script
# runs as user 'postgres', so we can execute the 'role' and 'database' resources
# as 'root' later on, passing the below credentials in the PG client.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
EOH
  not_if "echo '\connect' | PGPASSWORD=#{node['postgresql']['password']['postgres']} psql --username=postgres --no-password -h localhost"
  action :run
end


bash "create-database-user" do
  user 'postgres'
  coded = <<-EOH
  export PGPASSWORD=#{node['postgresql']['password']['postgres']}
  psql -U postgres -c "select * from pg_user where usename='#{node['postgresql']['database']['user']['username']}'" | grep -c #{node['postgresql']['database']['user']['username']}
EOH
  code <<-EOH
  export PGPASSWORD=#{node['postgresql']['password']['postgres']}
  createuser -U postgres -w -A -R -D -r -S -E #{node['postgresql']['database']['user']['username']}
EOH
  not_if coded
  action :run
end

bash "create-database" do
  user 'postgres'
  coded = <<-EOH
  export PGPASSWORD=#{node['postgresql']['password']['postgres']}
  psql -U postgres -c "select * from pg_database where datname='#{node['postgresql']['database']['name']}'" | grep -c #{node['postgresql']['database']['name']}
EOH
  code <<-EOH
  export PGPASSWORD=#{node['postgresql']['password']['postgres']}
  createdb -U postgres -w -O #{node['postgresql']['database']['user']['username']} -T template1 #{node['postgresql']['database']['name']}
EOH
  not_if coded
  action :run
end


bash "assign-user-password" do
  user 'postgres'
  code <<-EOH
  export PGPASSWORD=#{node['postgresql']['password']['postgres']}
   psql -U postgres -c "ALTER USER  #{node['postgresql']['database']['user']['username']} WITH ENCRYPTED PASSWORD '#{node['postgresql']['database']['user']['password']}';"
EOH
  action :run
end
