class ImportData

  # requirements to create the standalone environment for the job to run
  require 'rubygems'
  require 'active_record'
  require 'figaro'
  require 'yaml'
  require 'mysql2'
  require 'quickbooks-ruby'
  require 'oauth-plugin'

  puts "***** pwd: `pwd`"
  puts `pwd`

  require './app/classes/quickbooks_communicator'

  # Get sales_receipts => needs to be aggregated to a single record for each transaction_date in the last year

  models = [ 'user_import','user_address_import','quickbooks_auth_import','company_info_import','sales_receipt_import', 'invoice_import' ]

  # NOTE: This next line differs from the one in the 'standard_supply' ExportOrderData class in that
  # the rails framework there loads all of the classes so we can just call them there w/o any "../" stuff
  models.map! { |model| require "./app/models/#{model}.rb" }

  attr_accessor :rails_env, :current_path, :api_customer_id

  # TODO: read this in from secrets.yml
  QB_KEY = 'qyprda7A7mXjuUJJ8Zr9q6uOibccoB'
  QB_SECRET = 'EeVlrvwviyGoXBf8kkEp9V8h9kVYXr3QWEv4VGo9'

  def initialize(msg, rails_env, current_path, api_customer_id)
    puts msg

    $current_path     = current_path
    $api_customer_id  = api_customer_id
    $rails_env        = rails_env

    $qb_key     = 'qyprda7A7mXjuUJJ8Zr9q6uOibccoB'
    $qb_secret  = 'EeVlrvwviyGoXBf8kkEp9V8h9kVYXr3QWEv4VGo9'

    $qb_oauth_consumer = OAuth::Consumer.new($qb_key, $qb_secret, {
                                                       :site                 => "https://oauth.intuit.com",
                                                       :request_token_path   => "/oauth/v1/get_request_token",
                                                       :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
                                                       :access_token_path    => "/oauth/v1/get_access_token"
                                                   })


    Quickbooks.sandbox_mode = true

    create_db_connections(current_path)

  end

  def create_db_connections(current_path)

    puts "****** Creating DB Connection #{$rails_env}...#{current_path}"

    # NOTE: We instantiate the job in RAILS_ENV=development just to keep things "normal", but we want to access tables from the 'prediq_api_import_*' database
    # rails_env = "import_#{rails_env}"
    dbconfig = YAML.load(File.read("#{current_path}/config/database.yml"))["import_#{$rails_env}"]
    # NOTE: This is the current 'rails_env' database connection so all AR connections are to the current 'rails_env' database
    ActiveRecord::Base.establish_connection(dbconfig)
    $dbconn = ActiveRecord::Base.connection
    # puts "********* dbconfig: #{dbconfig}";puts;puts

  end

  def import_company_info_data(user)
    company_info = QuickbooksCommunicator.new(user.quickbooks_auth_import).company_info.first
    # puts "*********"
    # puts "company_info.attributes: #{company_info.attributes}"
    # NOTE: The => {"id"=>1, at the very start of the result is called the 'qb_company_info_id'
    qb_company_info_id = company_info['id']
    # puts "company_info['id']: #{qb_company_info_id}"
    # puts "**********************************"

    # Works: user_data = $dbconn.exec_query("SELECT * FROM prediq_api_#{$rails_env}.api_customer where customer_id = #{user.id} LIMIT 1").first
    # puts "********* user_data.class: #{user_data.class}"
    # puts "********* user_data: #{user_data['email']}"
    # puts "********* user_data.keys: #{user_data.keys}"

    # 1.  Delete the recs, if any, for the CustomerInfo data for that user
    $dbconn.execute("DELETE FROM prediq_api_import_#{$rails_env}.company_info_imports where qb_company_info_id = #{qb_company_info_id}")
    # 2. Use the company_info result and create a company_info_import

    # puts;puts "*** Creating CustomerInfoImport";puts
    # puts "******************************************************************************************"
    # puts customer_info_attribs(company_info, user.id)
    # puts "******************************************************************************************"

    CompanyInfoImport.create!(company_info_attribs(company_info, user.id))

    # TODO: 1. Create the AddressInfoImport table address_info_imports
    # TODO: 2. Iterate over the company_info['company_address'] => object and create AddressInfoImport records
    # connection = ActiveRecord::Base.connection
    # connection.execute("SQL query")
  end

  def import_sales_data(user, query_str)

    # user = UserImport.includes(:quickbooks_auth_import).find(api_customer_id)

    puts "***** user: #{user}"

    # delete all previous records from the *_imports tables for this user
    $dbconn.execute("DELETE FROM prediq_api_import_#{$rails_env}.sales_receipt_imports where api_customer_id = #{user.id}")

    # don't forget query_in_batches if we need to do that
    sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth_import).sales_receipts(query_str)

    puts "sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth).sales_receipts(#{query_str})"
    puts "*********************** sales_receipts.first: #{sales_receipts.first.txn_date}"
    puts
    puts "***** sales_receipt.count: #{sales_receipts.count}"

    # iterate over the SalesReceipt data and create one record at a time
    sales_receipts.each_with_index do |sales_receipt, idx|
      puts "**** Importing SalesReceipt#: #{idx+1}"
      SalesReceiptImport.create!(sales_receipt_attribs(sales_receipt, user.id))
    end

    # NOTE: By this time we already have a User (api_customer) created from the Quickbooks Customer_info data, so we get the user via its id
    # 1.  Delete the recs, if any, for the SalesReceipt data for that user

  end

  def import_invoices_data(user, query_str)

    # delete all previous records from the *_imports tables for this user
    $dbconn.execute("DELETE FROM prediq_api_import_#{$rails_env}.invoice_imports where api_customer_id = #{user.id}")

    invoices = QuickbooksCommunicator.new(user.quickbooks_auth_import).invoices(query_str)

    if invoices.count > 0

      puts "******"
      puts "***** invoices.count: #{invoices.count}"
      # puts invoices.first.attributes
      puts "******"

      # iterate over the Invoice data and create one record at a time
      invoices.each_with_index do |invoice, idx|
        puts "**** Importing Invoice#: #{idx+1}"
        InvoiceImport.create!(invoice_attribs(invoice, user.id))
      end

    else
      puts "******"
      puts "***** NO INVOICES data for this Company"
      puts "******"

    end


  end

  def copy_from_import_to_live(user, rails_env)
    # 1. Copy company info data from the prediq_api_import_#{rails_env}.company_info_imports table to the prediq_api_#{rails_env}.api_customer table,
    #    checking first if the prediq_api_#{rails_env}.api_customer.qb_company_info_id record is not already there, via 'qb_company_info_id'

    #   A). Clear out the data we are importing (if exists) from the prediq_api_#{$rails_env}.api_customer table
    #   NOTE: We may not want to do this here because the data may have already been added by the self-registration process

    # NOTE: next line for testing only so the insert into 'prediq_api_#{$rails_env}.api_customer' can be tested, comment out for PROD
    $dbconn.execute("DELETE FROM prediq_api_#{$rails_env}.api_customer where customer_id = #{user.id}")
    #   B). INSERT into the prediq_api_#{$rails_env}.api_customer table if it does not already exist (check via item 'qb_company_info_id')
    # Get the company_import_imports rec for the user we are importing now
    company_info_import_rec = CompanyInfoImport.where(api_customer_id: user.id).first
    if company_info_import_rec
      puts "*** CompanyInfoImport rec exists - can try the INSERT INTO 'api_customer'"
      # Check if the target table 'prediq_api_#{$rails_env}.api_customer' already has the company_import_import.qb_company_info_id for the user.
      # If not then do the INSERT, else raise an ERROR

      live_rec_to_create    = $dbconn.select_all("SELECT * FROM prediq_api_#{$rails_env}.api_customer WHERE customer_id = #{user.id} AND qb_company_info_id = #{company_info_import_rec.qb_company_info_id}")[0] #['customer_id']
      import_rec_to_insert  = $dbconn.select_all("SELECT * FROM prediq_api_import_#{$rails_env}.company_info_imports WHERE qb_company_info_id = #{company_info_import_rec.qb_company_info_id} AND api_customer_id = #{user.id}")[0] #['api_customer_id']

      if live_rec_to_create.nil? && import_rec_to_insert.present?
        # Insert the 'prediq_api_#{$rails_env}.api_customer' record using the 'prediq_api_import_#{$rails_env}.company_info_imports' data items
        puts "***** live_rec_to_create: #{live_rec_to_create}";puts
        puts "***** import_rec_to_insert: #{import_rec_to_insert}"

      else
        puts "ERROR: The api_customer record to create already exists"        if live_rec_to_create.present?
        puts "ERROR: The company_info_imports record to copy does not exist"  if import_rec_to_insert.nil?
      end

      # Now do the same for the live 'api_address' data, using the address info from the 'prediq_api_import_#{$rails_env}.company_info_imports' data

    else
      puts "**** ERROR: The company_info_import_rec for user #{user.id} does not exist"
    end

    # INSERT INTO users (full_name, login, password)
    # SELECT 'Mahbub Tito','tito',SHA1('12345') FROM DUAL
    # WHERE NOT EXISTS
    # (SELECT login FROM users WHERE login='tito');

    # 2. Copy company address info from the prediq_api_import_#{rails_env}.company_info_imports table to the prediq_api_#{rails_env}.api_address table,
    #    checking first if the prediq_api_#{rails_env}.api_customer.qb_company_address_id record is not already there, via 'qb_company_address_id'
=begin
PROCESS FLOW:
1.  User accesses the site, registers
  A. Does the Quickbooks Auth
  B. QB data from Company_Info comes back, used to populate a screen that the user:
    1. verifies items from the QB data in the "company_info_imports" table and the "address_info_imports" table:
      - company_name                                                     => api_customer.company_name *
      - customer_communication_address_line_1                            => api_customer.address_1    *
      - customer_communication_address_line_2                            => api_customer.address_2    *
      - customer_communication_address_city                              => api_customer.city         *
      - customer_communication_address_country_subdivision_code (state)  => api_customer.state        *
      - customer_communication_address_postal_code                       => api_customer.postal_code  *
      - primary_phone                                                    => api_customer.telephone    § (alt-6)
    2.  Is presented with various addresses (if more than one address) from the "address_info_imports" table
      a. user selects which one is "primary"
    3. verifies company_info_imports.email as the preferred login email, or changes it
    4. supplies the password and password_confirmation
  C. User submits, data is populated into the ??? TBD

* = (need to add item to api_customer)
§ = item already exists in api_customer

=end
  end

  def etl_sales_data(user)
  end

  private

  def company_info_attribs(company_info, api_customer_id)
    company_info_address  = company_info['company_address']
    comm_address          = company_info['customer_communication_address']
    legal_address         = company_info['legal_address']
    {
      api_customer_id:              api_customer_id,
      qb_company_info_id:           company_info['id'],
      sync_token:                   company_info['sync_token'],
      meta_data_create_time:        company_info['meta_data']['create_time'],
      # last_updated_time
      company_name:                 company_info['company_name'],
      legal_name:                   company_info['legal_name'],
      qb_company_address_id:        company_info_address['id'],
      qb_company_address_line_1:    company_info_address['line1'],
      qb_company_address_line_2:    company_info_address['line2'],
      qb_company_address_line_3:    company_info_address['line3'],
      qb_company_address_line_4:    company_info_address['line4'],
      qb_company_address_line_5:    company_info_address['line5'],
      qb_company_address_city:      company_info_address['city'],
      qb_company_address_country_sub_division_code:  company_info_address['country_sub_division_code'],
      qb_company_address_postal_code:   company_info_address['postal_code'],
      qb_company_address_lat:           company_info_address['lat'],
      qb_company_address_lon:           company_info_address['lon'],
      comm_address_id:               comm_address['id'],
      comm_address_line_1:           comm_address['line1'],
      comm_address_line_2:           comm_address['line2'],
      comm_address_line_3:           comm_address['line3'],
      comm_address_line_4:           comm_address['line4'],
      comm_address_line_5:           comm_address['line5'],
      comm_address_city:             comm_address['city'],
      comm_address_country_sub_division_code:     comm_address['country_sub_division_code'],
      comm_address_postal_code:      comm_address['postal_code'],
      comm_address_lat:              comm_address['lat'],
      comm_address_lon:              comm_address['lon'],
      legal_address_id:              legal_address['id'],
      legal_address_line_1:          legal_address['line1'],
      legal_address_line_2:          legal_address['line2'],
      legal_address_line_3:          legal_address['line3'],
      legal_address_line_4:          legal_address['line4'],
      legal_address_line_5:          legal_address['line5'],
      legal_address_city:            legal_address['city'],
      legal_address_country_sub_division_code:    legal_address['country_sub_division_code'],
      legal_address_postal_code:     legal_address['postal_code'],
      legal_address_lat:             legal_address['lat'],
      legal_address_lon:             legal_address['lon'],
      primary_phone:                 company_info['primary_phone']['free_form_number'],
      company_start_date:            company_info['company_start_date'],
      fiscal_year_start_month:       company_info['fiscal_year_start_month'],
      country:                       company_info['country'],
      email:                         company_info['email']['address']
    # supported_languages
    # Data Services Extensions
    #   harmony type of company
    #   forst transaction date
    #   industry type
    #   company type
    #   Offering SKU
    #   subscription status
    #   payroll type
    #   accountant enabled
    }
  end

  def sales_receipt_attribs(sales_receipt, api_customer_id)
    bill_address  = sales_receipt['bill_address']
    if sales_receipt['department_ref']
      department_ref        = sales_receipt['department_ref']
      department_ref_name   = (department_ref['name'])  ? department_ref['name']  : nil
      department_ref_value  = (department_ref['value']) ? department_ref['value'] : nil
      department_ref_type   = (department_ref['type'])  ? department_ref['type']  : nil
    else
      department_ref_name, department_ref_value, department_ref_type = nil, nil, nil
    end

    if sales_receipt['txn_tax_detail']
      txn_tax_detail    = sales_receipt['txn_tax_detail']
      txn_tax_code_ref  = (txn_tax_detail['txn_tax_code_ref'])  ? txn_tax_detail['txn_tax_code_ref']  : nil
      total_tax         = (txn_tax_detail['total_tax'])         ? txn_tax_detail['total_tax']         : nil
    else
      txn_tax_code_ref, total_tax = nil, nil
    end

    if sales_receipt['ship_address']
      ship_address                            = sales_receipt['ship_address']
      ship_address_id                         = ship_address['id']
      ship_address_line_1                     = ship_address['line1']
      ship_address_line_2                     = ship_address['line2']
      ship_address_line_3                     = ship_address['line3']
      ship_address_line_4                     = ship_address['line4']
      ship_address_line_5                     = ship_address['line5']
      ship_address_city                       = ship_address['city']
      ship_address_country_sub_division_code  = ship_address['country_sub_division_code']
      ship_address_postal_code                = ship_address['postal_code']
      ship_address_lat                        = ship_address['lat']
      ship_address_lon                        = ship_address['lon']
    else
      ship_address_id, ship_address_line_1, ship_address_line_2, ship_address_line_3, ship_address_line_4, ship_address_line_5, ship_address_city, ship_address_country_sub_division_code, ship_address_postal_code, ship_address_lat, ship_address_lon = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    {
      api_customer_id:              api_customer_id,
      qb_sales_receipt_id:          sales_receipt['id'],
      sync_token:                   sales_receipt['sync_token'], # not needed
      meta_data_create_time:        sales_receipt['meta_data']['create_time'],
      # last_updated_time
      transaction_date:             sales_receipt['txn_date'],
      # department_ref repeat like customer_ref, below
      customer_ref_name:            sales_receipt['customer_ref']['name'],
      customer_ref_value:           sales_receipt['customer_ref']['value'],
      customer_ref_type:            sales_receipt['customer_ref']['type'],
      department_ref_name:          department_ref_name ,
      department_ref_value:         department_ref_value,
      department_ref_type:          department_ref_type ,
      # customer_memo
      customer_memo:                (sales_receipt['customer_memo']) ? sales_receipt['customer_memo'] : nil,
      # private_note
      private_note:                (sales_receipt['private_note']) ? sales_receipt['private_note'] : nil,

      # linked_transaction_id
      linked_transaction_id:       (sales_receipt['linked_txn']) ? sales_receipt['linked_txn']['txn_id'] : nil,
      # transaction tax code (object) (detail)
      txn_tax_code_ref:            txn_tax_code_ref,
      total_tax:                   total_tax,

      bill_address_id:              bill_address['id'],
      bill_address_line_1:          bill_address['line1'],
      bill_address_line_2:          bill_address['line2'],
      bill_address_line_3:          bill_address['line3'],
      bill_address_line_4:          bill_address['line4'],
      bill_address_line_5:          bill_address['line5'],
      bill_address_city:            bill_address['city'],
      bill_address_country_sub_division_code: bill_address['country_sub_division_code'],
      bill_address_postal_code:     bill_address['postal_code'],
      bill_address_lat:             bill_address['lat'],
      bill_address_lon:             bill_address['lon'],

      ship_address_id:              ship_address_id,
      ship_address_line_1:          ship_address_line_1,
      ship_address_line_2:          ship_address_line_2,
      ship_address_line_3:          ship_address_line_3,
      ship_address_line_4:          ship_address_line_4,
      ship_address_line_5:          ship_address_line_5,
      ship_address_city:            ship_address_city,
      ship_address_country_sub_division_code: ship_address_country_sub_division_code,
      ship_address_postal_code:     ship_address_postal_code,
      ship_address_lat:             ship_address_lat,
      ship_address_lon:             ship_address_lon,
      # duplicate the above for ship_address info
      # shipping method
      # ship date
      sales_receipt_total:          sales_receipt['total']
      # bill email (end user customer's email address)
      # balance
      # payment ref method name, type, value
      # payment type
      # apply_after_tax_discount
      # currency_reference
      # exchange rate
      # global tax calc
      # home_total_amount
    }
  end

  def invoice_attribs(invoice, api_customer_id)
    bill_address  = invoice['billing_address']
    ship_address  = invoice['shipping_address']

    puts "***** invoice_attribs.ship_address: #{ship_address}";puts

    # NOTE: This is faster than doing a bunch of IIF's, as shown in the commented code, below
    ship_address_attribs =
      if ship_address.present?
        {
          ship_address_id:              ship_address['id'],
          ship_address_line_1:          ship_address['line1'],
          ship_address_line_2:          ship_address['line2'],
          ship_address_line_3:          ship_address['line3'],
          ship_address_line_4:          ship_address['line4'],
          ship_address_line_5:          ship_address['line5'],
          ship_address_city:            ship_address['city'] ,
          ship_address_country_sub_division_code: ship_address['country_sub_division_code'],
          ship_address_postal_code:     ship_address['postal_code'],
          ship_address_lat:             ship_address['lat'],
          ship_address_lon:             ship_address['lon'],
        }
      else
        {}
      end

    {
      api_customer_id:              api_customer_id,
      qb_invoice_id:                invoice['id'],
      sync_token:                   invoice['sync_token'],
      meta_data_create_time:        invoice['meta_data']['create_time'],
      doc_number:                   invoice['doc_number'],
      transaction_date:             invoice['txn_date'],
      customer_ref_name:            invoice['customer_ref']['name'],
      customer_ref_value:           invoice['customer_ref']['value'],
      customer_ref_type:            invoice['customer_ref']['type'],
      bill_address_id:              bill_address['id'],
      bill_address_line_1:          bill_address['line1'],
      bill_address_line_2:          bill_address['line2'],
      bill_address_line_3:          bill_address['line3'],
      bill_address_line_4:          bill_address['line4'],
      bill_address_line_5:          bill_address['line5'],
      bill_address_city:            bill_address['city'],
      bill_address_country_sub_division_code: bill_address['country_sub_division_code'],
      bill_address_postal_code:     bill_address['postal_code'],
      bill_address_lat:             bill_address['lat'],
      bill_address_lon:             bill_address['lon'],
      # ship_address_id:              (ship_address) ? ship_address['id']   : nil,
      # ship_address_line_1:          (ship_address) ? ship_address['line1']: nil,
      # ship_address_line_2:          (ship_address) ? ship_address['line2']: nil,
      # ship_address_line_3:          (ship_address) ? ship_address['line3']: nil,
      # ship_address_line_4:          (ship_address) ? ship_address['line4']: nil,
      # ship_address_line_5:          (ship_address) ? ship_address['line5']: nil,
      # ship_address_city:            (ship_address) ? ship_address['city'] : nil,
      # ship_address_country_sub_division_code: (ship_address) ? ship_address['country_sub_division_code'] : nil,
      # ship_address_postal_code:     (ship_address) ? ship_address['postal_code'] : nil,
      # ship_address_lat:             (ship_address) ? ship_address['lat'] : nil,
      # ship_address_lon:             (ship_address) ? ship_address['lon'] : nil,
      sales_term_ref_name:          invoice['sales_term_ref']['name'],
      sales_term_ref_value:         invoice['sales_term_ref']['value'],
      sales_term_ref_type:          invoice['sales_term_ref']['type'],
      due_date:                     invoice['due_date'],
      total_amount:                 invoice['total_amount'],
      balance:                      invoice['balance'],
      deposit:                      invoice['deposit'],
      bill_email_address:           invoice['bill_email_address']
    }.merge(ship_address_attribs)
  end



end

# passed in arguments from the run_load_pg_data.sh script:
func            = ARGV[0] # will only execute if the ARGV[0] param exists and it is set to 'get_first_yr', 'get_five_yr' or 'get_daily'
rails_env       = ARGV[1] # import_development, import_staging, import_production, used to get the correct database.yml settings
current_path    = ARGV[2]
api_customer_id = ARGV[3]

# To run the shell script that runs this job:
# Local (existing api_customer user #2):
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=2; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}
# Local (newly created/registered api_customer user #9):
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}
# which then runs the following command that actually runs the job:
# RAILS_ENV=development bundle exec ruby app/classes/import_data.rb get_first_yr development /Users/billkiskin/prediq/prediq_api 2

if func == "get_first_yr"

  # NOTE: By the time this runs we have already created an 'api_customer' user record via the sign_up flow
  puts;puts "********* Running get_first_yr job; rails_env = #{rails_env}; api_customer_id = #{api_customer_id}";puts

  # 1. Instantiate the class
  id = ImportData.new( "Starting ImportData Job, func = '#{func}': #{Time.now}", rails_env, current_path, api_customer_id )

  user = UserImport.includes(:quickbooks_auth_import).find(api_customer_id)

=begin

NOTE: Commented out for testing only, uncomment for live / prod

  # 2. write the CompanyInfo data to the CompanyInfoImport relation
  id.import_company_info_data(user)

  # 3. Import SalesReceipt data
  # Initial First Year import for the Sales Forecast
  # Calc the present date backwards one year for the query first year's sales receipt data
  query_date = (DateTime.now - 1.year).strftime('%Y-%m-%d')
  qb_entity = 'SalesReceipt'
  query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date}'"
  puts "********* query_str: #{query_str}"
  id.import_sales_data(user, query_str)

  # 4. Check if they have any Invoices
  query_date = (DateTime.now - 1.year).strftime('%Y-%m-%d')
  qb_entity = 'Invoice'
  query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date}'"

  id.import_invoices_data(user, query_str)
=end

  # 5. Split out the company info and the address info from the prediq_api_import_#{rails_env}.company_info_imports table
  #    and copy to the prediq_api_#{rails_env}.api_customer and the prediq_api_#{rails_env}.api_address tables, if the 
  #    corresponding data is not already there.
  # NOTE: When copying SalesReceipt data, look for some 'address_id' to attempt to correlate sales receipts with an address_id
  id.copy_from_import_to_live(user, rails_env)

  # Now create the Data Warehouse records, starting with the Customer dimension, then the F_Sales data
  # Note that I manually created a new api_customer user "Bill Kiskin" to mimic the new user signing up, as opposed to using an existing user.
  # We can then use that new customer to associate the ETL data with
=begin
  Sales Data needs to be captured in the following format:

    `PRIMKEY` int(11) NOT NULL AUTO_INCREMENT,
    `CUSTOMER_ID` int(11) DEFAULT NULL,        -- the api
    `address_id` int(11) NOT NULL,
    `SALES` float DEFAULT NULL,
    `TRANSACTION_DATE` date DEFAULT NULL,
    `INSERT_DATE` date DEFAULT NULL,
    PRIMARY KEY (`PRIMKEY`),
    KEY `F_SALES_CUST` (`CUSTOMER_ID`),
    KEY `F_SALES_DATE` (`TRANSACTION_DATE`),
    KEY `address_id` (`address_id`)

=end
  # TODO: In cases where there are BOTH SalesReceipt and Invoice data, we need to decide which to use...
end



=begin

  Initial User Flow:

    1. The user goes to the Prediq site and starts the QB Auth process which leads them to the QB site
    2. Get company_info after the User does their QB Auth at the QB site
    3. User is presented with the QB Company Info, adds their email and password and submits; user (api_customer) record
       created
    4. ImportData is called to get the first year's data using the api_customer and the quickbooks_auths tables which
       we get via the user's 'id' aka 'api_customer_id'



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
  $ bundle exec ruby app/classes/import_data.rb get_first_yr_data development /Users/billkiskin/prediq/prediq_api

**************************
To run this using the run_import_first_yr_data.sh shell script:

$ cd into the app root
A). Local development
$ current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}

B). staging:
$ current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=staging;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}

A). production (only runs 'do_pg_backups'):
$ current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=production;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}


=end


=begin
      t.integer :qb_company_info_id
      t.integer :sync_token
      t.timestamp :meta_data_create_time
      t.string :company_name
      t.string :legal_name
      t.integer :company_address_id
      t.string :company_address_line_1
      t.string :company_address_line_2
      t.string :company_address_line_3
      t.string :company_address_line_4
      t.string :company_address_line_5
      t.string :company_address_city
      t.string :company_address_country_sub_division_code
      t.string :company_address_postal_code
      t.decimal :company_address_lat, precision: 10, scale: 7
      t.decimal :company_address_lon, precision: 10, scale: 7
      t.integer :comm_address_id
      t.string :comm_address_line_1
      t.string :comm_address_line_2
      t.string :comm_address_line_3
      t.string :comm_address_line_4
      t.string :comm_address_line_5
      t.string :comm_address_city
      t.string :comm_address_country_sub_division_code
      t.string :comm_address_postal_code
      t.decimal :comm_address_lat, precision: 10, scale: 7
      t.decimal :comm_address_lon, precision: 10, scale: 7
      t.integer :legal_address_id
      t.string :legal_address_line_1
      t.string :legal_address_line_2
      t.string :legal_address_line_3
      t.string :legal_address_line_4
      t.string :legal_address_line_5
      t.string :legal_address_city
      t.string :legal_address_country_sub_division_code
      t.string :legal_address_postal_code
      t.decimal :legal_address_lat, precision: 10, scale: 7
      t.decimal :legal_address_lon, precision: 10, scale: 7
      t.string :primary_phone
      t.timestamp :company_start_date
      t.string :fiscal_year_start_month
      t.string :country
      t.string :email

[6] pry(main)> company_info.first.attributes
=> {"id"=>1,
 "sync_token"=>6,
 "meta_data"=>{"create_time"=>2014-10-20 05:35:32 -0500, "last_updated_time"=>2014-11-29 06:06:29 -0600},
 "company_name"=>"Wesley Robinson Sandbox Company",
 "legal_name"=>"Wesley Robinson Sandbox Company",
 "company_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "customer_communication_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "legal_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "primary_phone"=>{"free_form_number"=>nil},
 "company_start_date"=>Mon, 20 Oct 2014 00:00:00 +0000,
 "employer_id"=>nil,
 "fiscal_year_start_month"=>"January",
 "country"=>"US",
 "email"=>{"address"=>"noreply@quickbooks.com"},
 "web_site"=>{"uri"=>nil},
 "supported_languages"=>"en"}

=end

=begin

[6] pry(main)> sales_receipts.first.attributes
=> {"global_tax_calculation"=>nil,
 "id"=>47,
 "sync_token"=>0,
 "meta_data"=>{"create_time"=>2014-11-01 13:40:52 -0500, "last_updated_time"=>2014-11-01 13:40:52 -0500},
 "auto_doc_number"=>nil,
 "doc_number"=>"1014",
 "txn_date"=>2014-10-30 00:00:00 -0500,
 "line_items"=>
  [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Weekly Gardening Service, amount: 140.0, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>,
   #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 140.0, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>],
 "customer_ref"=>{"name"=>"Diego Rodriguez", "value"=>"4", "type"=>nil},
 "bill_email"=>{"address"=>"Diego@Rodriguez.com"},
 "bill_address"=>
  {"id"=>66,
   "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>nil,
   "country"=>nil,
   "country_sub_division_code"=>nil,
   "postal_code"=>nil,
   "note"=>nil,
   "lat"=>"37.4530553",
   "lon"=>"-122.1178261"},
 "ship_address"=>nil,
 "po_number"=>nil,
 "ship_method_ref"=>nil,
 "ship_date"=>nil,
 "tracking_num"=>nil,
 "payment_method_ref"=>nil,
 "payment_ref_number"=>nil,
 "deposit_to_account_ref"=>{"name"=>"Undeposited Funds", "value"=>"4", "type"=>nil},
 "customer_memo"=>"Thank you for your business and have a great day!",
 "private_note"=>nil,
 "total"=>#<BigDecimal:7fb0734ed7e0,'0.14E3',9(18)>}

      t.integer   :api_customer_id
      t.integer   :customer_id
      t.integer   :address_id
      t.integer   :qb_sales_receipt_id
      t.timestamp :transaction_date
      t.timestamp :meta_data_create_time
      t.decimal   :sales_receipt_total, precision: 7, scale: 2
      t.string    :customer_ref
      t.integer   :bill_address_id
      t.string    :customer_ref_name
      t.integer   :customer_ref_value
      t.string    :customer_ref_type
      t.integer   :bill_address_id
      t.string    :bill_address_line_1
      t.string    :bill_address_line_2
      t.string    :bill_address_line_3
      t.string    :bill_address_line_4
      t.string    :bill_address_line_5
      t.string    :bill_address_city
      t.string    :bill_address_country_sub_division_code
      t.string    :bill_address_postal_code
      t.decimal   :bill_address_lat, precision: 10, scale: 7
      t.decimal   :bill_address_lon, precision: 10, scale: 7

=end

=begin

t.integer     :api_customer_id
t.integer     :address_id
t.integer     :qb_invoice_id
t.integer     :sync_token
t.timestamp   :meta_data_create_time
t.integer     :doc_number
t.timestamp   :transaction_date
t.decimal     :total_tax, precision: 7, scale: 2                    # txn_tax_detail_total_tax
t.string      :customer_ref_name
t.integer     :bill_address_id
t.string      :bill_address_line_1
t.string      :bill_address_line_2
t.string      :bill_address_line_3
t.string      :bill_address_line_4
t.string      :bill_address_line_5
t.string      :bill_address_city
t.string      :bill_address_country_sub_division_code
t.string      :bill_address_postal_code
t.decimal     :bill_address_lat, precision: 10, scale: 7
t.decimal     :bill_address_lon, precision: 10, scale: 7
t.integer     :ship_address_id
t.string      :ship_address_line_1
t.string      :ship_address_line_2
t.string      :ship_address_line_3
t.string      :ship_address_line_4
t.string      :ship_address_line_5
t.string      :ship_address_city
t.string      :ship_address_country_sub_division_code
t.string      :ship_address_postal_code
t.decimal     :ship_address_lat, precision: 10, scale: 7
t.decimal     :ship_address_lon, precision: 10, scale: 7
t.string      :sales_term_ref_name
t.integer     :sales_term_ref_value
t.string      :sales_term_ref_type
t.timestamp   :due_date
t.decimal     :total_amount, precision: 8, scale: 2
t.decimal     :balance, precision: 8, scale: 2
t.decimal     :deposit, precision: 8, scale: 2
t.string      :bill_email_address

[3] pry(main)> invoices.first.attributes
=> {"global_tax_calculation"=>nil,
 "id"=>130,
 "sync_token"=>0,
 "meta_data"=>{"create_time"=>2014-11-03 15:16:17 -0600, "last_updated_time"=>2014-11-03 15:16:17 -0600},
 "custom_fields"=>[#<Quickbooks::Model::CustomField id: 1, name: Crew #, type: StringType, string_value: 102, boolean_value: nil, date_value: nil, number_value: nil>],
 "auto_doc_number"=>nil,
 "doc_number"=>"1037",
 "txn_date"=>Mon, 03 Nov 2014,
 "currency_ref"=>nil,
 "exchange_rate"=>nil,
 "private_note"=>nil,
 "linked_transactions"=>[#<Quickbooks::Model::LinkedTransaction txn_id: 100, txn_type: Estimate, txn_line_id: nil>],
 "line_items"=>
  [#<Quickbooks::Model::InvoiceLineItem id: 1, line_num: 1, description: Rock Fountain, amount: 275.0, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7f8049756360,'0.275E3',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7f804975f988,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: 2, line_num: 2, description: Fountain Pump, amount: 12.75, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Pump", "value"=>"11", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7f80497741f8,'0.1275E2',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7f804977d898,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: 3, line_num: 3, description: Concrete for fountain installation, amount: 47.5, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Concrete", "value"=>"3", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7f804979e1d8,'0.95E1',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7f80497a7878,'0.5E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: nil, line_num: nil, description: nil, amount: 335.25, detail_type: SubTotalLineDetail, sales_line_item_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil>],
 "txn_tax_detail"=>
  {"txn_tax_code_ref"=>{"name"=>nil, "value"=>"2", "type"=>nil},
   "total_tax"=>#<BigDecimal:7f80497cd550,'0.2682E2',18(18)>,
   "lines"=>
    [#<Quickbooks::Model::TaxLine id: nil, line_num: nil, description: nil, amount: 26.82, detail_type: TaxLineDetail, tax_line_detail: {"percent_based?"=>true, "net_amount_taxable"=>#<BigDecimal:7f80497dd5e0,'0.33525E3',18(18)>, "tax_inclusive_amount"=>nil, "override_delta_amount"=>nil, "tax_percent"=>#<BigDecimal:7f80497e6aa0,'0.8E1',9(18)>, "tax_rate_ref"=>{"name"=>nil, "value"=>"3", "type"=>nil}}>]},
 "customer_ref"=>{"name"=>"Sonnenschein Family Store", "value"=>"24", "type"=>nil},
 "customer_memo"=>"Thank you for your business and have a great day!",
 "billing_address"=>
  {"id"=>95,
   "line1"=>"Russ Sonnenschein\nSonnenschein Family Store\n5647 Cypress Hill Ave.\nMiddlefield, CA  94303",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>nil,
   "country"=>nil,
   "country_sub_division_code"=>nil,
   "postal_code"=>nil,
   "note"=>nil,
   "lat"=>"37.4238562",
   "lon"=>"-122.1141681"},
 "shipping_address"=>
  {"id"=>25,
   "line1"=>"5647 Cypress Hill Ave.",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"Middlefield",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"94303",
   "note"=>nil,
   "lat"=>"37.4238562",
   "lon"=>"-122.1141681"},
 "class_ref"=>nil,
 "sales_term_ref"=>{"name"=>nil, "value"=>"3", "type"=>nil},
 "due_date"=>Wed, 03 Dec 2014,
 "ship_method_ref"=>nil,
 "ship_date"=>nil,
 "tracking_num"=>nil,
 "ar_account_ref"=>nil,
 "total_amount"=>#<BigDecimal:7f804a030120,'0.36207E3',18(18)>,
 "home_total_amount"=>nil,
 "apply_tax_after_discount?"=>false,
 "print_status"=>"NeedToPrint",
 "email_status"=>"NotSet",
 "balance"=>#<BigDecimal:7f804a043978,'0.36207E3',18(18)>,
 "deposit"=>#<BigDecimal:7f804a042b18,'0.0',9(18)>,
 "department_ref"=>nil,
 "allow_ipn_payment?"=>false,
 "bill_email"=>{"address"=>"Familiystore@intuit.com"},
 "allow_online_payment?"=>false,
 "allow_online_credit_card_payment?"=>false,
 "allow_online_ach_payment?"=>false}

[26] pry(main)> cust_fields = invoices.first.custom_fields.first
=> #<Quickbooks::Model::CustomField id: 1, name: Crew #, type: StringType, string_value: 102, boolean_value: nil, date_value: nil, number_value: nil>
[27] pry(main)> cust_fields
=> #<Quickbooks::Model::CustomField id: 1, name: Crew #, type: StringType, string_value: 102, boolean_value: nil, date_value: nil, number_value: nil>
[28] pry(main)> cust_fields['name']
=> "Crew #"
[29] pry(main)> cust_fields['type']
=> "StringType"
[30] pry(main)> cust_fields['string_value']
=> "102"
[31] pry(main)> cust_fields['boolean_value']
=> nil
[32] pry(main)> cust_fields['date_value']
=> nil
[33] pry(main)> cust_fields['number_value']
=> nil

=end
