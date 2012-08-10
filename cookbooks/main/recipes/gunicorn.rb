execute 'create virtual env' do
  command 'export WORKON_HOME=$HOME/.virtualenvs'
  command 'source /usr/local/bin/virtualenvwrapper.sh'
  command 'workon ' + node["python"]["virtualenv_name"]
  command 'pip install gunicorn'
end
