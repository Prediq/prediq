class ImportFirstYrData

  # requirements to create the standalone environment for the job to run
  require 'rubygems'
  require 'active_record'
  require 'figaro'
  require 'yaml'
  require 'mysql2'
  require 'quickbooks-ruby'

  puts "***** pwd: `pwd`"
  puts `pwd`

  require './app/classes/quickbooks_communicator'

  # Get sales_receipts => needs to be aggregated to a single record for each transaction_date in the last year

  models = [ 'customer_info_import','sales_receipt_import' ]

  # NOTE: This next line differs from the one in the 'standard_supply' ExportOrderData class in that
  # the rails framework there loads all of the classes so we can just call them there w/o any "../" stuff
  models.map! { |model| require "./app/models/#{model}.rb" }

  attr_accessor :rails_env, :current_path, :user_id

  def initialize(msg, rails_env, current_path, user_id)
    puts msg

    $current_path = current_path
    $user_id      = user_id

    create_db_connections(rails_env, current_path)

  end

  def create_db_connections(rails_env, current_path)

    puts "****** Creating DB Connection #{rails_env}...#{current_path}"

    dbconfig = YAML.load(File.read("#{current_path}/config/database.yml"))[rails_env]
    # NOTE: This is the current 'rails_env' database connection so all AR connections are to the current 'rails_env' database
    ActiveRecord::Base.establish_connection(dbconfig)

    puts "********* dbconfig: #{dbconfig}";puts;puts

  end

  def import_data(user_id, )

  end

end

# passed in arguments from the run_load_pg_data.sh script:
func          = ARGV[0] # will only execute if the ARGV[0] param exists and it is set to 'restore_latest_heroku_backups', 'do_full_heroku_backups' or 'get_backups'
rails_env     = ARGV[1] # import_development, import_staging, import_production, used to get the correct database.yml settings
current_path  = ARGV[2]
user_id       = ARGV[3]

# To run the shell script that runs this job:
# Local:
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr_data;rails_env=import_development;user_id=2; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_first_yr_data.sh ${func} ${rails_env} ${current_path} ${user_id}
# which then issues the following command tgat actually runs the job:
# RAILS_ENV=import_development bundle exec ruby app/classes/import_first_yr_data.rb get_first_yr_data import_development /Users/billkiskin/prediq/prediq_api 2

if func == "get_first_yr_data"

  puts;puts "********* Running import_first_yr_data rails_env = #{rails_env}";puts

  ify = ImportFirstYrData.new( "Starting ImportFirstYrData Job: #{Time.now}", rails_env, current_path, user_id )

  ify.import_data(user_id, )

end



=begin

  Initial User Flow:

    1. The user goes to the Prediq site and starts the QB Auth process which leads them to the QB site
    2. Get company_info after the User does their QB Auth at the QB site
    3. User is presented with the QB Company Info, adds their email and password and submits; user (api_customer) record
       created
    4. ImportFirstYrData is called to get the first year's data



To get quickbooks data at the console:

1. In a browser log in as user 2 "tc2@bigmagma.com" authenticate QB to create the user and create the QuickbooksAuth
record for that user so we can next hit QB for the data
  a. dashboard page, click Connect to QB as you can use wes@prediq.com pr3d1q

2. In console
  a. user = User.find 2
  b. company_info = QuickbooksCommunicator.new(user.quickbooks_auth).company_info
  c. sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth).sales_receipts


**************************
To run this from the app's root in a bash terminal session:

$ cd into the app root
Local:
  $ bundle exec ruby app/classes/import_first_yr_data.rb get_first_yr_data development /Users/billkiskin/prediq/prediq_api
  OR
  $ bundle exec ruby classes/import_first_yr_data.rb get_first_yr_data development /Users/billkiskin/prediq/prediq_api_import
**************************
To run this using the run_import_first_yr_data.sh shell script:

$ cd into the app root
A). production (only runs 'do_pg_backups'):
$ current_path=/var/www/vhosts/pg_data/current;func=do_pg_backups;rails_env=production; cd ${current_path} && app/classes/run_load_pg_data.sh ${func} ${rails_env} ${current_path}

B). staging (only runs the 'restore_pg_backups'):
$ current_path=/var/www/vhosts/pg_data/current;func=restore_pg_backups;rails_env=staging; cd ${current_path} && app/classes/run_load_pg_data.sh ${func} ${rails_env} ${current_path}

=end
