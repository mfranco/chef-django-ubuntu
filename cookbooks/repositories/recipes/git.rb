dev_dir = node['repositories']['path']
puts dev_dir
repos = node['repositories']['git'] || []

repos.each do |repo|
  git 'Clone repo' do
    user node['user']['default']['username']
    group node['user']['default']['username']
    repository repo['url']
    action :checkout
    destination dev_dir + repo['name']
  end
end
