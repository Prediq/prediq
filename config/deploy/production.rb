#############################################################
#	Application /ruby-1.9.3-p448@fet
#############################################################

set :application, "standard_supply"
set :app_name,  'api-socialcentiv-production'
set :app_uri,   "unknown.com"
set :deploy_to, "/var/www/vhosts/#{app_uri}"
set :gem_home, "/home/deploy/.rvm/gems/ruby-2.0.0-p353@standard_supply"
set :gem_path, "/home/deploy/.rvm/gems/ruby-2.0.0-p353@standard_supply:/home/deploy/.rvm/gems/ruby-2.0.0-p353@global" # got these last 2 via "gem info" on the app server's app root

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :chmod755, "app config db lib public vendor script script/* public/*"
set :ssh_options, { :forward_agent => true }
set :use_sudo, false
set :scm_verbose, true
set :with_db_settings, false # on a database server specific setup, this will be set to true in the db_server:setup task
set :rails_env, "production"
set :bundle_flags, "--deployment"
set :rvm_shell, '/home/deploy/.rvm/bin/rvm-shell'

#############################################################
#	Servers
#############################################################

set :user, "deploy"
set :db_user, "root"
#set :domain, "166.78.179.216"
set :domain, "162.242.148.122"
set :port, 922
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	git
#############################################################

set :scm, :git
set :repository, "git@github.com:semaphoremobile/StandardSupply-AppServer.git"
set :branch, "master"

# production-specific tasks here

# https://moocode.com/posts/1-deploying-a-rails-3-1-application-to-production
# after 'deploy:update_code' do
#   puts "precompiling assets"
#   run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
# end


=begin

http://help.github.com/capistrano/ says:

Known Hosts bug

If you are not using agent forwarding, the first time you deploy may fail due to Capistrano not prompting with this message:

The authenticity of host 'github.com (207.97.227.239)' can't be established.
RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)?

To fix this, ssh into your server as the user you will deploy with, run ssh git@github.com and confirm the prompt.

=end