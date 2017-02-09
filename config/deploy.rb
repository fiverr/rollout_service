require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'json'


set :user, 'admin'
set :deploy_to, "/home/admin/apps/rollout_service"
set :repository, "git@github.com:fiverr/rollout_service.git"
set :keep_releases, 10

app_root = %x[pwd].strip
version = File.read("#{app_root}/.ruby-version").strip
if File.exist?("#{app_root}/.ruby-gemset")
  gemset = File.read("#{app_root}/.ruby-gemset").strip
else
  version, gemset = version.split("@")
end
set_default :current_ruby, version
set_default :current_gemset, gemset


if ENV['branch'].nil? || ENV['branch'].empty?
  set :branch, 'master'
else
  set :branch, "#{ENV['branch']}"
end

begin
  raise "Domain is not defined." if ENV['domain'].nil? || ENV['domain'].empty?
  raise "Environment not set ['production', 'staging']." if ENV['env'].nil? || ENV['env'].empty?
  raise "App is not defined ['worker', 'service', 'both']." if ENV['app'].nil? || ENV['app'].empty?
rescue => e
  puts e
  puts "try :: mina deploy domain=<%server%> env=<%['production', 'staging']%> app=<%['worker', 'service', 'both']%>"
  exit
end

set :domain, ENV['domain']
puts "Domain :: #{domain}"

set :env, ENV['env']
puts "Environment :: #{env}"

set :app, ENV['app']
puts "App :: #{app}"

set :versionsBack, ENV['versionsBack']
puts "versionsBack :: #{versionsBack}"

set :shared_paths, ['var', 'log', 'tracker', 'pid']

invoke :"deploy:force_unlock"

task :environment do
  invoke :"rvm:use[#{current_ruby!}@#{current_gemset!}]"
end

# Put any custom mkdir's in here for when `mina setup` is ran.
task :setup  do
  shared_paths.each do |path|
    queue! %[mkdir -p "/tmp/var/rollout_service/"]
    queue! %[chmod a+rw "/tmp/var/rollout_service/"]

    queue! %[mkdir -p "#{deploy_to}/shared/#{path}"]
    queue! %[chmod a+rw "#{deploy_to}/shared/#{path}"]

    queue! %[mkdir -p "#{deploy_to}/releases"]
    queue! %[chmod a+rw "#{deploy_to}/releases"]
  end
end

task :update_current_symlink => :environment do
  queue %[echo -n "-----> updating current link for stats worker: "]
  queue %[ls -ltr #{deploy_to}/current | awk '{print "ln -nsf", "#{deploy_to}/"$11"/rollout_service #{deploy_to}/current"}' | bash]
  queue %[cd #{deploy_to}/current]
end

task :build_config_files => :environment do
  queue %[cd #{deploy_to}/current]
  queue %[chmod g+rx,u+rwx "./etc/build_config_files.sh"]
  queue %[bash etc/build_config_files.sh #{deploy_to}]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :setup
    invoke :'git:clone'
    to :launch do
      invoke :'update_current_symlink'
      in_directory "#{deploy_to}/current" do
        invoke :'deploy:link_shared_paths'
        invoke :'bundle:install'
        invoke :build_config_files
        invoke :restart_app
        @commands[:default] = commands(@to)
      end
      invoke :'deploy:cleanup'
    end
  end
end

desc "Rolls back to previous release."
task :rollbackPrevious => :environment do
  queue! %[echo "-----> Rolling back to previous release for instance: #{domain}"]
#  Delete existing sym link and create a new symlink pointing to the previous release
  queue %[echo -n "-----> Creating new symlink from the previous release: "]
  queue! %[ls -ltr #{deploy_to}/current | awk -F/ '{print "find #{deploy_to}/releases -maxdepth 1 ! -newer #{deploy_to}/releases/"$NF" | grep -v", $NF}' | bash | awk -F\/ '{print $NF}' | sort -n | tail -1| xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current"]
  invoke :restart_app
end

desc "Rolls back to a version older than previous."
task :rollbackOlderThanPrevious => :environment do
  queue %[echo "-----> Rolling #{versionsBack} versions back for instance: #{domain}"]
  queue! %[ls -ltr #{deploy_to}/current | awk -F/ '{print "find #{deploy_to}/releases -maxdepth 1 ! -newer #{deploy_to}/releases/"$NF" | grep -v", $NF}' | bash | awk -F\/ '{print $NF}' | sort -n | tail -#{versionsBack} | head -1 | xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current"]
  invoke :restart_app
end

desc "Restarts app/worker from current location"
task :restart_app do
  queue %[cd #{deploy_to}/current]
  queue %[chmod g+rx,u+rwx "./etc/control.sh"]
  queue %[./etc/control.sh restart #{env} ./etc/rollout_service_unicorn.rb]
end
