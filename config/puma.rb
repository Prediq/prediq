#!/usr/bin/env puma

# config/puma.rb
# start puma manually with:
# RAILS_ENV=staging bundle exec puma -C ./config/puma.rb

railsenv          = ENV["RAILS_ENV"]
application_path  = "/var/www/vhosts/prediq_api_#{railsenv}.com/current"

if railsenv != 'development' || railsenv.empty?
  directory application_path
  environment railsenv
  pidfile         "#{application_path}/tmp/pids/puma-#{railsenv}.pid"
  state_path      "#{application_path}/tmp/pids/puma-#{railsenv}.state"
  stdout_redirect "#{application_path}/log/puma-#{railsenv}.stdout.log", "#{application_path}/log/puma-#{railsenv}.stderr.log"
  bind            "unix:///tmp/prediq_api_#{railsenv}.com.sock"
  threads 0, 16
end
#activate_control_app "unix:///tmp/api.socialcentiv-#{railsenv}.com.sock"

on_worker_boot do
  require 'active_record'
  require 'pg'
  require 'pry'
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  cwd       = "../" + File.dirname(__FILE__)

  puts "********* ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"

  dbconfig  = YAML.load_file("config/database.yml")[ENV["RAILS_ENV"]] rescue false

  puts "*********** ENV: #{ENV}"
  puts `ENV`

  puts "************ INSIDE puma.rb's on_worker_boot do dbconfig: #{dbconfig}"

  ActiveRecord::Base.establish_connection(dbconfig)
end

=begin

NOTE: The 'ENV["RAILS_ENV"]' variable is created and passed to this script by the Procfile:

  web: bundle exec puma -e development -p 5000 -S ~/puma -C config/puma.rb

  NOTE: On staging and production, to start the server on the correct environment to test puma you should run

    RAILS_ENV=<ENVIRONMENT> bundle exec puma -e <ENVIRONMENT> -S ~/puma -C config/puma.rb

    alternatively, you can run sudo puma-manager-staging start to start the app

Where puma gets its 'development' env set, and

To start foreman in a particular environment from, say the app root such as '/Users/billkiskin/hiplogiq/api-socialcentiv-com':

$ foreman start -e config/environments/development.env

It is important to configure the number of threads and workers correctly, and the Puma README offers some advice on
how best to do this. To run Puma in clustered mode, you will need at least two workers. Generally you should match
the number of cores available on your VPS. On Ubuntu you can use the command:

grep -c processor /proc/cpuinfo

# config/puma.rb
threads 1, 6
workers 2

on_worker_boot do
  require "active_record"
  cwd = File.dirname(__FILE__)+"/.."
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || YAML.load_file("#{cwd}/config/database.yml")[ENV["RAILS_ENV"]])
end
=end
