=begin

For a first time deploy or to blow away the data tables and repopulate from seeds.rb:

"capify ."

"cap <stage> deploy:setup"

Thereafter:

"cap staging deploy"

then "cap staging deploy:migrations" on the local

OR

"RAILS_ENV=staging bundle exec rake db:setup" on the remote server

NOTE: This will woprk once you add the task to deploy.rb
cap staging deploy:seed

To run a console on the remote:
RAILS_ENV=staging bundle exec rails c

In case you need to run "cap deploy:setup" again and you don’t want Capistrano to ask for a database password,
set the skip_db_setup option to true. This is especially useful in combination with capistrano multi-stage
recipe when you already setup your server and you share the same environment across all the stages.

$ cap deploy:setup -s "skip_db_setup=true"

after that do a "cap deploy:cold" (does migrations) and when that is good do a:

rake db:setup


sudo vi /etc/apache2/sites-available/www.miinfo.com.gt

sudo /etc/init.d/apache2 restart

sudo apache2ctl restart

NOTE:  If you are using Carrierwave to upload files be sure and create the "shared/public/uploads/" dir.  The deploy scripts
symlink "public/uploads" to this location but Capistrano does not actually create it for you.

NOTE: In order to get www.miinfo.com.gt running in true production mode we had to jump through a few hoops...
First was the assets:precompile task.  I added it to the /deploy/production.rb file but it really didn't need to be there.

1.  All you have to do is make sure this line: "load 'deploy/assets'" is active in the Capfile.  That is what triggers the
    Capistrano assets:precompile task

2.  In the Gemfile you need this:

    group :assets do
      gem 'sass-rails', "3.1.4"
      gem 'coffee-rails', "~> 3.1.0"
      gem 'uglifier'
    end

    What is particular about this is that the version of 'sass-rails' must be 3.1.4.  I was using 3.1.5 and threw a "stack level too deep" error
    during the precompile task. See https://github.com/rails/sass-rails/issues/78

3.  On the server: sudo vi /etc/apache2/sites-available/www.miinfo.com.gt
    and make sure that the vhost file in /etc/apache2/sites-available/www.miinfo.com.gt looks like this:

    <VirtualHost *:80>
      ServerAlias www.miinfo.com.gt
      DocumentRoot /var/www/vhosts/www.miinfo.com.gt/current/public
      <Directory /var/www/vhosts/www.miinfo.com.gt/current/public>
         AllowOverride all
         Options -MultiViews
      </Directory>

      RailsEnv  production
    </VirtualHost>

4.  Restart apache

    "sudo apache2ctl restart" or "sudo /etc/init.d/apache2 restart"

=end

set :stages, %w(staging production)
set :default_stage, "staging"
set :shared_children, shared_children + %w{public/uploads}
set :shared_children, shared_children + %w{public/downloads}

#set :ssh_options, { :keys => "~/.ssh/FADMobile.pem" }

puts "ENV['HOME']: #{ENV['HOME']}"

# Carrierwave uploads folder
#set :shared_children, shared_children + %w{public/uploads}
# inspired by: https://groups.google.com/forum/?fromgroups=#!topic/capistrano/MroQsb7d_rA

# to not have cap staging deploy:setup create root-owned directories
set :use_sudo, false

# inspired by: http://stackoverflow.com/questions/12641837/define-bundle-path-with-capistrano
bundle_cmd = "/home/deploy/.rvm/gems/ruby-1.9.3-p374@global/gems/bundler-1.3.5/bin/bundle"
set :bundle_cmd, bundle_cmd
set :bundle_dir, "/home/deploy/.rvm/gems/ruby-1.9.3-p374"

require 'bundler/capistrano'

require 'capistrano/ext/multistage'

puts "ENV['rvm_path']"
puts "rvm_path => #{ENV['rvm_path']}"
puts "END ENV['rvm_path']"

puts ENV['rails_env']

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.

#require "rvm/capistrano"                                # Load RVM's capistrano plugin.

set :rvm_ruby_string, 'ruby-1.9.3-p374@idakey'               # ruby-1.9.3-p374 Or whatever env you want it to run in.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')

set :rvm_bin_path, "$HOME/.rvm/bin"
set :rvm_type, :user

puts "******************* deploy.rb: require capistrano_database **********************"

require "capistrano_database"

# namespace :db do
#   desc 'Migrate DB down, up, seed'
#   # run like: cap staging deploy db:seed
#   task :seed do
#     run "rake db:seed"
#   end
# end

namespace :deploy do

  desc "Restarting mod_rails with restart.txt, capistrano runs this by default"
  task :restart, :roles => :app, :except => { :no_release => true } do
    puts "************ running => task :restart, :roles => :app, :except => { :no_release => true }"
    run "touch #{current_path}/tmp/restart.txt"
  end

  # NOTE: you must manually create the "#{shared_path}/config/" dir since capistrano does not create a "config" dir for you
  # unless you have already run "cap <stage> deploy:setup" which would have created the dir and put the database.yml into it

  desc 'moves the current .rvmrc into #{shared_path/config/.rvmrc and symlinks it'
  namespace :rvmrc do
    task :symlink, :except => { :no_release => true } do
      puts "************ running: deploy.rb: symlinking .rvmrc: ln -nfs #{shared_path}/config/.rvmrc #{release_path}/config/.rvmrc"
      run "mv -vf #{release_path}/.rvmrc #{shared_path}/config/.rvmrc"
      puts "************ running: ln -nfs #{shared_path}/config/.rvmrc #{release_path}/.rvmrc"
      # run "ln -nfs .rvmrc #{shared_path}/config/.rvmrc"
      run "ln -nfs #{shared_path}/config/.rvmrc #{release_path}/.rvmrc"
    end
  end

  desc "symlinks the /public/uploads folder to be shared/public/uploads/ so the Carrierwave uploaded images are not lost each deploy"
  # NOTE: once "cap <stage> deploy:setup has been run from the local you must manually create the dirs on the server:
  # mkdir -v  /var/www/vhosts/staging.aad.org/shared/public
  # mkdir -v  /var/www/vhosts/cms.aadmobileapp.org/shared/public/uploads
  namespace :carrierwave do
    task :symlink, :except => { :no_release => true } do
      puts "************ running: deploy.rb: symlinking /public/uploads: rm -rf #{latest_release}/public/uploads && ln -s #{shared_path}/public/uploads #{latest_release}/public/uploads"
      run "rm -rfv #{latest_release}/public/uploads && ln -sv #{shared_path}/public/uploads #{latest_release}/public/uploads"
    end
  end

  # scp config/config.yml deploy@ec2-184-73-28-247.compute-1.amazonaws.com:/var/www/vhosts/staging.aad.org/shared/config/
  # scp config/config.yml deploy@cms.aadmobileapp.org:/var/www/vhosts/cms.aadmobileapp.org/shared/config/
  desc 'symlinks the secure copied file #{shared_path/config/config.yml. NOTE: you must scp first this file to /var/www/vhosts/staging.aad.org/shared/config/'
  namespace :config do
    task :symlink, :except => { :no_release => true } do
      puts "************ running: deploy.rb: symlinking config.yml: ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
      run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
    end
  end

  # scp config/my_config.yml deploy@ec2-184-73-28-247.compute-1.amazonaws.com:/var/www/vhosts/staging.aad.org/shared/config/
  # scp config/my_config.yml deploy@cms.aadmobileapp.org:/var/www/vhosts/cms.aadmobileapp.org/shared/config/
  desc 'symlinks the secure copied file #{shared_path/config/my_config.yml. NOTE: you must scp first this file to /var/www/vhosts/staging.aad.org/shared/config/'
  namespace :my_config do
    task :symlink, :except => { :no_release => true } do
      puts "************ running: deploy.rb: symlinking my_config.yml: ln -nfs #{shared_path}/my_config/config.yml #{release_path}/config/my_config.yml"
      run "ln -nfs #{shared_path}/config/my_config.yml #{release_path}/config/my_config.yml"
    end
  end

  desc "reload the database with seed data"
  task :seed do
    puts "***************** seeding the database **************************"
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end

  # NOTE: For security the aad.yml needs to be kept out of git and manually copied up so it can be symlinked here
  # scp config/aad.yml deploy@ec2-184-73-28-247.compute-1.amazonaws.com:/var/www/vhosts/staging.aad.org/shared/config/
  # scp config/aad.yml deploy@cms.aadmobileapp.org:/var/www/vhosts/cms.aadmobileapp.org/shared/config/
  desc "symlinks the current aad.yml into shared/config/aad.yml (must be scp'd up there first)"
  namespace :rackspace do
    task :symlink, :except => { :no_release => true } do
      #puts "************ running: deploy.rb: symlinking rackspace.yml: mv -vf #{release_path}/config/initializers/fog.rb #{shared_path}/config/fog.rb"
      #run "mv -vf #{release_path}/config/initializers/fog.rb #{shared_path}/config/fog.rb"
      puts "************ running: ln -nfs #{shared_path}/config/aad.yml #{release_path}/config/aad.yml"
      # run "ln -nfs .rvmrc #{shared_path}/config/.rvmrc"
      run "ln -nfs #{shared_path}/config/aad.yml #{release_path}/config/aad.yml"
    end
  end

  desc "symlinks the /public/downloads folder to be shared/public/downloads/ so the CAAD downloaded providers json file can live there between deploys"
  # NOTE: once "cap <stage> deploy:setup has been run from the local you must manually create the dirs on the server:
  # mkdir -v  /var/www/vhosts/staging.aad.org/shared/public/downloads
  # mkdir -v  /var/www/vhosts/cms.aadmobileapp.org/shared/public/downloads
  namespace :aad_providers do
    task :symlink, :except => { :no_release => true } do
      puts "************ running: deploy.rb: symlinking /public/downloads: rm -rf #{latest_release}/public/downloads && ln -s #{shared_path}/public/downloads #{latest_release}/public/downploads"
      run "rm -rfv #{latest_release}/public/downloads && ln -sv #{shared_path}/public/downloads #{latest_release}/public/downloads"
    end
  end

  # NOTE:  the variables RAILS_SHARED_PATH, RAILS_CURRENT_PATH are used to pass their values into wheneverize's schedule.rb
  desc "Update crontab from whenever configuration"
  task :wheneverize, :roles => :db do
    #if rails_env == "production"
      # :bundle_cmd
    puts "*************** bundle_cmd #{bundle_cmd} *******************"
      #run "cd #{current_path} && RAILS_ENV=#{rails_env} RAILS_SHARED_PATH=#{shared_path} RAILS_CURRENT_PATH=#{current_path} bundle exec whenever --update-crontab #{application}"
      run "cd #{current_path} && RAILS_ENV=#{rails_env} RAILS_SHARED_PATH=#{shared_path} RAILS_CURRENT_PATH=#{current_path} #{bundle_cmd} exec whenever --update-crontab #{application}"
    #end
  end

  # NOTE: the database.yml was created and symlinked by config/deploy/_database.rb, called by "cap deploy:setup", so we do not have a symlink task for that in this script

  ## NOTE: For security the scout_rails.yml needs to be kept out of git and manually copied up so it can be symlinked here
  #desc "symlinks the current scout_rails.yml into shared/config/scout_rails.yml (must be scp'd up there first)"
  #namespace :scout_rails do
  #  task :symlink, :except => { :no_release => true } do
  #    puts "************ running: ln -nfs #{shared_path}/config/scout_rails.yml #{release_path}/config/scout_rails.yml"
  #    run "ln -nfs #{shared_path}/config/scout_rails.yml #{release_path}/config/scout_rails.yml"
  #  end
  #end

end # namespace :deploy do

after "deploy", "deploy:wheneverize"
after "deploy:create_symlink", "deploy:rvmrc:symlink"
after "deploy:rvmrc:symlink", "deploy:carrierwave:symlink"
after "deploy:carrierwave:symlink", "deploy:aad_providers:symlink"
before "deploy:assets:precompile",  "deploy:config:symlink"
before "deploy:assets:precompile",  "deploy:my_config:symlink"

#after "deploy:carrierwave:symlink", "deploy:rackspace:symlink"

#after "deploy:rackspace:symlink", "deploy:scout_rails:symlink"


=begin
  http://merbist.com/2011/08/30/deploying-a-rails-3-1-app-gotchas/ has some good advice on deploying
=end