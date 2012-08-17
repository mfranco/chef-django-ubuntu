python_packages = ['virtualenvwrapper', 'ipdb', 'ipython', 'supervisor', 'mercurial', 'fabric']

python_packages.each do |python_package|
  execute 'install python packages' do
    command 'pip install ' + python_package
    action :run
  end
end

python_virtualenv 'create_virtualenv' do
  action 'create'
  path node['python']['virtualenv']['path']
  owner node['python']['virtualenv']['owner']
  group node['python']['virtualenv']['group']
end
