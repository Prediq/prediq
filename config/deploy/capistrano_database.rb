#
# = Capistrano database.yml task
#
# Provides a couple of tasks for creating the database.yml
# configuration file dynamically when deploy:setup is run.
#
# Category::    Capistrano
# Package::     Database
# Author::      Simone Carletti
# Copyright::   2007-2009 The Authors
# License::     MIT License
# Link::        http://www.simonecarletti.com/
# Source::      http://gist.github.com/2769
#
# http://www.simonecarletti.com/blog/2009/06/capistrano-and-database-yml/
=begin
In case you need to run deploy:setup again and you don’t want Capistrano to ask for a database password,
set the skip_db_setup option to true. This is especially useful in combination with capistrano multi-stage
recipe when you already setup your server and you share the same environment across all the stages.

$ cap deploy:setup -s "skip_db_setup=true"
=end

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do
  namespace :db do
    desc "Initialize the db and its configs on a database server that will NOT have git installed"
    task :init_db, roles: :db, except: { no_release: true } do
      set :with_db_settings, true
      # shorewall.setup

=begin
        6(db). download postgres and setup user and database
          
          A. su - postgres && psql

          B. CREATE USER socialcompass with PASSWORD '1x3Ekwals3' SUPERUSER CREATEDB CREATEROLE

          C. create databases

            i. CREATE DATABASE "api-socialcentiv-com_development"

            ii. CREATE DATABASE "api-socialcentiv-com_test"

            iii. CREATE DATABASE "api-socialcentiv-com_staging"

            iv. CREATE DATABASE "api-socialcentiv-com_production"

          D. Enable remote connections

            i. edit /etc/postgresql/[VERSION]/main/pg_hba.conf

            ii. append the addresses of all remote staging or production servers (echo "host     all             all             23.253.227.126          md5" >> /etc/postgresql/9.3/main/pg_hba.conf)

            iii. edit /etc/postgresql/[VERSION]/main/postgreql.conf

            iv. append * listen addresses (shorewall will block all unallowed connections) (echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf)

          E. Restart Postgres 

            i. sudo service postgresql restart

          F. Add TCP and UDP rules for postgres to shorewall and restart it

            i. echo  "ACCEPT          net             fw              tcp     5432" >> /etc/shorewall/rules

            ii. echo  "ACCEPT          net             fw              udp     5432" >> /etc/shorewall/rules

            iii. sudo shorewall restart

            iv. TEST connection on clients! psql -h 23.253.227.126 -U socialcompass -d api-socialcentiv-com_staging

            v. Database server is fully setup!

=end
      dbcs = ["development", "test", "staging", "production"] #db_creation_strings

      ( 0..dbcs.length-1 ).each { |i| dbcs[ i ] = "createdb #{ application }_#{ dbcs[ i ] }" }

      run "#{sudo} sudo su - postgres -c \"#{ dbcs.join(' && ') }\""

      db_pass = Capistrano::CLI.ui.ask('Enter Postgres database password (it should be the same as the password you just typed in): ')
      db_str  = "create user socialcompass with password \'#{ db_pass }\' superuser createdb createrole"
      run "#{sudo} sudo su - postgres -c \"psql -c \\\"#{db_str}\\\"\""
      #run "#{sudo} sudo su - postgres -c \"createuser -s -P socialcompass \""


      app_local_domains.split(',').each do |dom|
        run "echo \"host     all             all             #{ "#{dom}/32".ljust(20) } md5\" | #{sudo} tee -a /etc/postgresql/#{pg_version}/main/pg_hba.conf"
      end

      #dev_ip_addresses.split(',').each do |dom|
      #  next if dom.blank? || dom.nil?
      #  run "echo \"host     all             all             #{ dom+('/32').ljust(20) } md5\" | #{sudo} tee -a /etc/postgresql/#{pg_version}/main/pg_hba.conf"          
      #end

      run "echo \"listen_addresses='*'\" | #{sudo} tee -a /etc/postgresql/#{pg_version}/main/postgresql.conf"
    end

    desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template
      called database.yml.erb is found either in :template_dir
      or /config/deploy folders. The default template matches
      the template for config/database.yml file shipped with Rails.

      When this recipe is loaded, db:setup is automatically configured
      to be invoked after deploy:setup. You can skip this task setting
      the variable :skip_db_setup to true. This is especially useful
      if you are using this recipe in combination with
      capistrano-ext/multistaging to avoid multiple db:setup calls
      when running deploy:setup for all stages one by one.
    DESC
    task :setup, roles: :app, :except => { :no_release => true } do

      default_template = <<-EOF
      base: &base
        adapter: mysql2
        timeout: 5000
      development:
        database: #{shared_path}/db/development.sqlite3
        <<: *base
      test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
      production:
        database: #{shared_path}/db/production.sqlite3
        <<: *base
      EOF

      location = fetch(:template_dir, "config/deploy/file_templates") + '/database.yml.erb'
      template = File.file?(location) ? File.read(location) : default_template

      config = ERB.new(template)

      puts "************ running: capistrano_database.rb: mkdir -p #{shared_path}/db"
      run "mkdir -p #{shared_path}/db"
      puts "capistrano_database.rb: mkdir -p #{shared_path}/config"
      run "mkdir -p #{shared_path}/config"
      puts "capistrano_database.rb: 'config.result(binding)', #{shared_path}/config/database.yml"
      put config.result(binding), "#{shared_path}/config/database.yml"
    end

    desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true } do
      puts "************ running: capistrano_database.rb: symlinking database.yml: ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end


    desc "Restart Postgres"
    task :restart_postgres, roles: :db do
      run "#{sudo} service postgresql restart"

      puts "####################################################################"
      puts "Remember to TEST postgres on clients! Run the following command:"
      puts "psql -h #{db_local_domain} -U socialcompass -d #{app_name}_#{rails_env}\n"
      puts "If everything works you should see the psql prompt"
      puts "####################################################################"
    end
  end

  puts "capistano_database.rb: NEXT: db:setup"
  after "deploy:setup", "db:setup"      unless fetch(:skip_db_setup, false)
  after "deploy:setup", "db:init_db"    unless fetch(:skip_db_init, false)
  after "db:init_db", "db:restart_postgres"

  # This runs during a basic deploy, not "cap deploy:setup" so the symlink gets made on a "cap staging deploy"
  # It has to be done then so we have the app's structure in place, which is where the config/database.yml exists
  puts "capistano_database.rb: NEXT: after deploy:finalize_update, db:symlink"
  after "deploy:finalize_update", "db:symlink"
end