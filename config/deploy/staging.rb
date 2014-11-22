#############################################################
#	Application ruby-2.1.1
#############################################################

set :application, 'prediq_api_staging.com'
set :app_name,  'prediq_api_staging'
set :app_uri,   application
set :deploy_to, "/var/www/vhosts/#{app_uri}"
set :gem_home, "/home/deploy/.rvm/gems/ruby-2.1.5@prediq_api"
set :gem_path, "/home/deploy/.rvm/gems/ruby-2.1.5@prediq_api:/home/deploy/.rvm/gems/ruby-2.1.5@global" # got these last 2 via "gem info" on the app server's app root
# set :pg_version, "9.3"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :chmod755, "app config db lib public vendor script script/* public/*"
set :ssh_options, { :forward_agent => true }
set :use_sudo, true
set :scm_verbose, true
set :rails_env, 'staging'
set :bundle_flags, '--deployment'
set :rvm_shell, '/home/deploy/.rvm/bin/rvm-shell'

#############################################################
#    Servers
#############################################################

app_server1 = 'ruby1-prediq.brownrice.com' #see note below on role :app
# app_server2 = 'apisc02.socialcentiv.biz'

set :user, 'deploy'
set :db_user, 'prediq_RbyApiU'
set :app_domains, "#{app_server1}" #comma delim string of servers (these must be ip-addresses)
# set :app_domains, "#{app_server1},#{app_server2}" #comma delim string of servers (these must be ip-addresses)
# set :app_local_domains, '10.208.171.251,10.208.171.93' #same as above
set :app_local_domains, '192.168.1.121' #same as above
#set :dev_ip_addresses, '' #these ip addresses are added to the pg_hba file so devs or admins can access the database from their machines through a database browser
set :db_domain, 'mysql1-prediq.brownrice.com'
set :db_local_domain, '192.168.1.123'

set :app_role, false
set :port, 22
role(:app) { [ app_server1, { app_role: true } ] }
role :web, app_server1 #, app_server2
role :db, db_domain, :primary => true
#############################################################
#	git
#############################################################

set :scm, :git
set :repository, 'git@github.com:Prediq/prediq.git'
# set :branch, 'master'
set :branch, 'master_staging'
#set :repository_cache, "git_cache"
# set :deploy_via, :remote_cache         # http://help.github.com/capistrano/ says: In most cases you want to use this option, otherwise each deploy will do a full repository clone every time.
#set :deploy_via, :checkout
#set :checkout, "export"
#set :scm_user, user


=begin

http://help.github.com/capistrano/ says:

Known Hosts bug

If you are not using agent forwarding, the first time you deploy may fail due to Capistrano not prompting with this message:

The authenticity of host 'github.com (207.97.227.239)' can't be established.
RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)?

To fix this, ssh into your server as the user you will deploy with, run ssh git@github.com and confirm the prompt.

=end