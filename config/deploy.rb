require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')
# prompts for DB password and ip address (or hostname), symlinks database.yml
require "capistrano_database"
require "nginx_config_generator"
require "puma_config_generator"
# require "shorewall_config_generator"


=begin

For a first time deploy or to blow away the data tables and repopulate from seeds.rb:

"capify ."

To copy the database.yml securely to the shared/config/database.yml
"cap <stage> deploy:setup"

To create and copy the apache2 vhost file:
"cap <any stage> deploy -s "create_vhost_apache=true"
cap staging deploy -s "create_vhost_apache"

cap <stage> deploy:db:create

Thereafter:

rvm install ruby-2.0.0-p195

"cap staging deploy"

cap staging deploy:migrate

then "cap staging deploy:migrations" on the local

OR

"RAILS_ENV=staging bundle exec rake db:setup" on the remote server
"RAILS_ENV=staging bundle exec rake db:create" on the remote server

NOTE: This will work once you add the task to deploy.rb
cap staging deploy:seed

To run a console on the remote:
RAILS_ENV=staging bundle exec rails c

In case you need to run "cap deploy:setup" again and you don’t want Capistrano to ask for a database password,
set the skip_db_setup option to true. This is especially useful in combination with capistrano multi-stage
recipe when you already setup your server and you share the same environment across all the stages.

$ cap deploy:setup -s "skip_db_setup=true"

after that do a "cap deploy:cold" (does migrations) and when that is good do a:

rake db:setup
=end

# set :app_name, 'prediq_api'  # set in staging.rb as
set :user, 'deploy'

# for the rvm-capistrano gem:
set :rvm_ruby_string, :local               # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"        # more info: rvm help autolibs
set :rvm_ruby_string, 'ruby-2.1.5@prediq'
# for the create_vhost_apache task
set :ruby_path, '/home/deploy/.rvm/rubies/ruby-2.1.5/bin/ruby'

set :bundle_path, '/home/deploy/.rvm/gems/ruby-2.1.5@global/bin/bundle'

set :keep_releases, 10

set :stages, %w(staging production)
set :default_stage, 'staging'

# Carrierwave uploads folder
# set :shared_children, shared_children + %w{public/uploads}  # creates the "shared/uploads" dir

# cap staging db:seed
namespace :db do
  desc 'Migrate DB down, up, seed'
  # run like: cap staging deploy db:seed
  task :seed, roles: :db do
    run "rake db:seed"
  end
end


namespace :deploy do

  # desc "Restarting mod_rails with restart.txt, capistrano runs this by default"
  # task :restart, :roles => :app, :except => { :no_release => true } do
  #   puts "************ running => task :restart, :roles => :app, :except => { :no_release => true }"
  #   run "touch #{current_path}/tmp/restart.txt"
  # end

  desc "Puts the deploy directories under the deploy user's name if they aren't already"
  task :chmod_deploy_directories do
    run "#{sudo} mkdir -p /var/www"
    run "#{sudo} chown -R deploy:www-data /var/www"
  end

  desc "Restarting upstart / foreman / puma, capistrano runs this by default"
  task :restart, roles: :app, except: { no_release: true } do
    puts "************ running => task :restart, :roles => :app, :except => { :no_release => true }"
    #foreman.export
    # on OS X the equivalent pid-finding command is `ps | grep '/puma' | head -n 1 | awk {'print $1'}`
    #run "(kill -s SIGUSR1 $(ps -C ruby -F | grep '/puma' | awk {'print $2'})) || #{sudo} service #{app_name} restart"
    #foreman.restart
    # foreman.restart # uncomment this (and comment line above) if we need to read changes to the procfile

    services.restart
  end

  desc "If the releases folder has more than 10 items in it, deletes all of the releases past the 10th"
  task :cleanup_releases, roles: :app, except: { no_release: true } do
    run "#{sudo} ls -1dt /var/www/vhosts/#{app_uri}/releases/* | tail -n +11 | xargs rm -rf"
  end 

  # NOTE: you must manually create the "#{shared_path}/config/" dir since capistrano does not create a "config" dir for you
  # unless you have already run "cap <stage> deploy:setup" which would have created the dir and put the database.yml into it
  # cd /car/www/
  # sudo chown -R deploy:www-data vhosts/


  namespace :figaro do
    desc "SCP transfer figaro configuration to the shared folder"
    task :setup, roles: :app do
      transfer :up, "config/application.yml", "#{shared_path}/config/application.yml", :via => :scp
    end

    desc "Symlink application.yml to the release path"
    task :symlink, roles: :app do
      run "ln -sf #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    end
  end

  namespace :database_yml do
    desc "SCP transfer the config/database.yml to the shared config folder"
    task :setup, roles: :app do
      #transfer :up, "config/database.yml", "#{shared_path}/config/database.yml", :via => :scp
      db.setup
    end

    desc "Symlink database.yml to the release path"
    task :symlink, roles: :app do
      run "ln -sf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
end
=begin
  set :application, 'standard_supply'
  set :app_uri,   'staging.standardsupplycms.com'
  set :deploy_to, "/var/www/vhosts/#{app_uri}"
  set :gem_home, "/home/deploy/.rvm/gems/ruby-2.0.0-p353@standard_supply"
  set :gem_path, "/home/deploy/.rvm/gems/ruby-2.0.0-p353@standard_supply:/home/deploy/.rvm/gems/ruby-2.0.0-p353@global" # got these last 2 via "gem info" on the app server's app root
=end

namespace :procfile do
  desc "symlinks the correct Procfile version based on the current 'rails_env' "
  task :symlink, roles: :app do
    puts "************** rails_env: #{rails_env}"
    puts "******** running ln -sf Procfile_#{rails_env} Procfile"

    puts ''
    puts `ls -l #{current_path}/`

    run "ln -sf #{current_path}/Procfile_#{rails_env} #{current_path}/Procfile"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, roles: :app do
    # run "#{sudo} touch /etc/init/#{app_name}.conf"
    # run "#{sudo} chown deploy:deploy /etc/init/#{app_name}.conf"
    # sudo "cd #{current_path} && bundle exec foreman export upstart /etc/init -a #{app_name} -d /var/www/vhosts/#{app_uri}/current -u #{user} -l /var/#{app_name}/log"
    # app_name => 'api-socialcentiv-staging'
    # on the apisc01 server, create the new '/etc/init/api-socialcentiv-staging' dir and set its permissions to 0755 and ownership to www-data:deploy
    # root@api-sc-01:/etc/init# chown 0755 api-socialcentiv-staging/
    # root@api-sc-01:/etc/init# chown www-data:deploy api-socialcentiv-staging/
    # root@api-sc-01:/etc/init# chown -R www-data:deploy api-socialcentiv-staging/../
    # sudo "cd #{current_path} && bundle exec foreman export upstart /etc/init/#{app_name} -a #{app_name} -d /var/www/vhosts/#{app_uri}/current -u #{user} -l /var/#{app_name}/log"
    # run "cd #{current_path} && bundle exec foreman export upstart /etc/init/#{app_name} -a #{app_name} -d /var/www/vhosts/#{app_uri}/current -u #{user} -l /var/#{app_name}/log"
    
    # dumps upstart config files into /etc/init (the puma specific ones we have setup are better)
    run "cd #{current_path} && bundle exec foreman export upstart /home/deploy/upstart -a #{app_name} -d #{current_path} -u #{user} -l /var/#{app_name}/log"
    # puts `who`
    # run "cd #{current_path} && export rvmsudo_secure_path=1 && rvmsudo bundle exec foreman export upstart /home/deploy/upstart -a #{app_name} -d /var/www/vhosts/#{app_uri}/current -u #{user} -l /var/#{app_name}/log"

    # run "#{sudo} cp #{current_path}/config/deploy/#{app_name}-puma.conf #{current_path}/config/deploy/puma-manager-#{rails_env}.conf /home/deploy/upstart" 
    # run "cd /home/deploy/upstart && #{sudo} mv -f * /etc/init"
    puma.move_config_files
  end
end

namespace :services do
  desc "Start the application services"
  task :start, roles: :app do
    run "#{sudo} service nginx start"
    run "#{sudo} service puma-manager start"
    #run "#{sudo} start #{app_name}-puma app=#{current_path}"
    #run "#{sudo} start #{app_name}"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    #run "#{sudo} stop #{app_name}"
    run "#{sudo} service nginx stop"
    run "#{sudo} service puma-manager stop"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    #run "#{sudo} start #{app_name} || #{sudo} restart #{app_name}"
    run "#{sudo} service nginx start || #{sudo} service nginx restart"
    run "#{sudo} service puma-manager start || #{sudo} service puma-manager restart"
  end
end

# after "deploy:update_code",         "deploy:create_vhost_apache"
# after "deploy:update_code",         "deploy:create_vhost_nginx"
before  "deploy:update_code",         "deploy:chmod_deploy_directories"
after   "deploy:create_symlink",      "deploy:figaro:setup"   # create_symlink is a default cap task that symlinks the latest release to current
after   "deploy:figaro:setup",        "deploy:figaro:symlink"
after   'deploy:figaro:symlink',      'deploy:database_yml:symlink' #'procfile:symlink'
# after   'procfile:symlink',           'deploy:database_yml:symlink'
# #after 'procfile:symlink',           'foreman:export'
after :deploy, 'deploy:cleanup' # there is not an implicit cleanup task so we explicitly call it
# after :deploy, 'deploy:cleanup_releases'



# after "deploy:figaro:symlink",      "deploy:carrierwave:symlink"
# parse
# after 'deploy:carrierwave:symlink', 'deploy:parse:setup'
# after 'deploy:parse:setup',         'deploy:parse:symlink'



=begin
  namespace :db do
    desc "creates database & database user"
    task :create do
      set :root_password, Capistrano::CLI.password_prompt("MySQL root password: ")
      set :db_user, Capistrano::CLI.ui.ask("Application database user: ")
      set :db_pass, Capistrano::CLI.password_prompt("Password: ")
      set :db_name, Capistrano::CLI.ui.ask("Database name: ")
      run "mysql --user=root --password=#{root_password} -e \"CREATE DATABASE IF NOT EXISTS #{db_name} CHARACTER SET utf8 COLLATE utf8_general_ci\""
      run "mysql --user=root --password=#{root_password} -e \"GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'localhost' IDENTIFIED BY '#{db_pass}' WITH GRANT OPTION\""
    end
  end

=end
