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

  models = [ 'user_import','user_address_import','quickbooks_auth_import','company_info_import','address_info_import','sales_receipt_import', 'invoice_import' ]

  # NOTE: This next line differs from the one in the 'standard_supply' ExportOrderData class in that
  # the rails framework there loads all of the classes so we can just call them there w/o any "../" stuff
  models.map! { |model| require "./app/models/#{model}.rb" }

  attr_accessor :rails_env, :current_path, :api_customer_id

  # TODO: read this in from secrets.yml
  QB_KEY = 'qyprda7A7mXjuUJJ8Zr9q6uOibccoB'
  QB_SECRET = 'EeVlrvwviyGoXBf8kkEp9V8h9kVYXr3QWEv4VGo9'
  BATCH_SIZE = 1000
  ADDRESS_TYPES = %w( company comm legal)


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

    puts "**** Importing CompanyInfo#";puts

    # Iterate over the each of the 3 address types in the company_info object and create AddressInfoImport records
    $dbconn.execute("DELETE FROM prediq_api_import_#{$rails_env}.address_info_imports where api_customer_id = #{user.id} AND qb_company_info_id = #{qb_company_info_id}")
    ADDRESS_TYPES.each do |address_type|
      puts "***** importing #{address_type}_address_info";puts
      AddressInfoImport.create!(company_address_attribs(company_info, address_type, user.id, qb_company_info_id))
    end

    qb_company_info_id

  end

  def import_sales_receipts(user, query_str)

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
    num_recs = 0
    sales_receipts.each_with_index do |sales_receipt, idx|
      puts "**** Importing SalesReceipt#: #{idx+1}"
      SalesReceiptImport.create!(sales_receipt_attribs(sales_receipt, user.id))
      num_recs += 1
    end
    num_recs
=begin
    NOTE: This is not the right way to query in batches.  Probably have to go into QuickbooksCommunicator
    sales_receipts.query_in_batches(nil, per_page: BATCH_SIZE) do |batch|
      batch.each do |sales_receipt|
        cntr += 1
        puts "**** Importing SalesReceipt#: #{cntr}"
        SalesReceiptImport.create!(sales_receipt_attribs(sales_receipt, user.id))
      end
    end
    cntr
=end
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

  def etl_company_info(user, qb_company_info_id, rails_env)
    # INSERT the the company_info_imports records into the dimension table d_company_info
    $dbconn.execute("
      INSERT INTO prediq_dw_#{rails_env}.d_company_info(
        qb_company_info_id,
        api_customer_id,
        -- attributes
        sync_token,
        meta_data_create_time,
        meta_data_update_time,
        company_name,
        legal_name,
        primary_phone,
        company_start_date,
        fiscal_year_start_month,
        country,
        email,
        created_at)
      SELECT
        qb_company_info_id,
        api_customer_id,
        sync_token,
        meta_data_create_time,
        meta_data_update_time,
        company_name,
        legal_name,
        primary_phone,
        company_start_date,
        fiscal_year_start_month,
        country,
        email,
        NOW()
      FROM prediq_api_import_#{rails_env}.company_info_imports ci
      WHERE ci.api_customer_id = #{user.id} AND ci.qb_company_info_id = #{qb_company_info_id}
      AND NOT EXISTS (SELECT api_customer_id FROM prediq_dw_#{rails_env}.d_company_info
        WHERE
          api_customer_id     = ci.api_customer_id AND
          qb_company_info_id  = ci.qb_company_info_id );")

    ADDRESS_TYPES.each do |address_type|
      puts "***** etl_address_info #{address_type}_address_info";puts
      # NOTE: we go through the motions of inserting into AddressInfoImport first then into d_company_address
      # in case we later need to do some transformations OR use data from AddressInfoImport for something in d_company_address,
      # such as calculating the nearest weather station
      etl_address_info(user, qb_company_info_id, address_type, rails_env)
    end

  end

  def etl_get_latpoints(user, qb_company_info_id, address_type, rails_env)
    result = $dbconn.execute("
      SELECT
        lat as latpoint,
        lon as longpoint
      FROM prediq_api_import_#{rails_env}.address_info_imports ai
      WHERE ai.api_customer_id = #{user.id} AND ai.qb_company_info_id = #{qb_company_info_id} and ai.address_type = '#{address_type}'").first

    # result = $dbconn.execute("
    #   SELECT
    #     lat as latpoint,
    #     lon as longpoint
    #   FROM prediq_api_import_development.address_info_imports ai
    #   WHERE ai.api_customer_id = 9 AND ai.qb_company_info_id = 1 and ai.address_type = 'comm'")

    # latpoint  = result.first[0]
    # longpoint = result.first[1]

    {latpoint: result[0], longpoint: result[1]}

  end

  def etl_address_info(user, qb_company_info_id, address_type, rails_env)
    # NOTE: Needs to ensure that we don't operate on a NULL value for lat or long so that we don't send a null value into
    # NOTE: The lat / lon for the QB sample address data is in Spain (36.6788345, -5.4464622) so we updated the coords
    # to be in Dallas (32.775, -96.7967) just so we can see weather_stations_id = 331
=begin
  update prediq_api_import_development.address_info_imports set lat = 32.775, lon = -96.7967 where id > 0;
=end
    $dbconn.execute("update prediq_api_import_development.address_info_imports set lat = 32.775, lon = -96.7967 where id > 0;") # NOTE: remove for PROD

    latpoints = etl_get_latpoints(user, qb_company_info_id, address_type, rails_env)
    puts "****** "
    # Haversine great circle formula
    #  http://www.plumislandmedia.net/mysql/haversine-mysql-nearest-loc/
    $dbconn.execute("
      INSERT INTO prediq_dw_#{rails_env}.d_company_address(
        address_type,
        api_customer_id,
        qb_company_info_id,
        qb_company_address_id,
        weather_stations_id,
        line_1,
        line_2,
        line_3,
        line_4,
        line_5,
        city,
        country,
        country_sub_division_code,
        postal_code,
        lat,
        lon)
      SELECT
        address_type,
        api_customer_id,
        qb_company_info_id,
        qb_company_address_id,
        (SELECT dws.weather_station_id
         FROM prediq_dw_development.d_weather_station dws
         JOIN
           (
              SELECT
            #{latpoints[:latpoint]}  as latpoint,
            #{latpoints[:longpoint]} as longpoint
          --  32.7758  as latpoint,
          --  -96.7967 as longpoint
            ) AS p ON 1=1
          ORDER BY
           111.045* DEGREES(ACOS(COS(RADIANS(latpoint))
             * COS(RADIANS(dws.lat))
             * COS(RADIANS(longpoint) - RADIANS(dws.`long`))
             + SIN(RADIANS(latpoint))
             * SIN(RADIANS(dws.lat)))) LIMIT 1),
        line_1,
        line_2,
        line_3,
        line_4,
        line_5,
        city,
        country,
        country_sub_division_code,
        postal_code,
        lat,
        lon
      FROM prediq_api_import_#{rails_env}.address_info_imports ai
      WHERE ai.api_customer_id = #{user.id} AND ai.qb_company_info_id = #{qb_company_info_id} and ai.address_type = '#{address_type}'
      AND NOT EXISTS (SELECT api_customer_id FROM prediq_dw_#{rails_env}.d_company_address
        WHERE
          api_customer_id     = ai.api_customer_id AND
          qb_company_info_id  = ai.qb_company_info_id AND
          address_type        = '#{address_type}');")
  end

  def etl_sales_receipts(user, rails_env)
    user_id = user.id
    # INSERT the the sales_receipt_imports records into the dimension table d_sales_receipt
    $dbconn.execute("
      INSERT INTO prediq_dw_#{rails_env}.d_sales_receipt(
        -- keys
        date_key,                -- aka TRANSACTION_DATE in the F_SALES table
        api_customer_id,
        api_address_id,
        weather_stations_id,
        -- attributes
        qb_sales_receipt_id,
        sync_token,
        transaction_date,        -- aka DATE_KEY
        meta_data_create_time,
        meta_data_update_time,
        sales_receipt_total,
        bill_address_id,
        bill_address_line_1,
        bill_address_line_2,
        bill_address_line_3,
        bill_address_line_4,
        bill_address_line_5,
        bill_address_city,
        bill_address_country_sub_division_code,
        bill_address_postal_code,
        bill_address_lat,
        bill_address_lon,
        bill_email_address,
        ship_address_id,
        ship_address_line_1,
        ship_address_line_2,
        ship_address_line_3,
        ship_address_line_4,
        ship_address_line_5,
        ship_address_city,
        ship_address_country_sub_division_code,
        ship_address_postal_code,
        ship_address_lat,
        ship_address_lon,
        ship_method_ref_name,
        ship_method_ref_value,
        ship_method_ref_type,
        ship_date,
        department_ref_name,
        department_ref_value,
        department_ref_type,
        payment_method_ref_name,
        payment_method_ref_value,
        payment_method_ref_type,
        customer_ref_name,
        customer_ref_value,
        customer_ref_type,
        balance,
        payment_type,
        currency_ref,
        exchange_rate,
        global_tax_calculation,
        home_total_amount,
        apply_after_tax_discount,
        customer_memo,
        private_note,
        linked_transaction_id,
        txn_tax_code_ref,
        total_tax,
        created_at
      )
      SELECT
        sri.transaction_date,
        sri.api_customer_id,
        a.address_id,
        0,                        -- NOTE: Need to get this using the lat / lng of the primary address
        sri.qb_sales_receipt_id,
        sri.sync_token,
        sri.transaction_date,
        sri.meta_data_create_time,
        sri.meta_data_update_time,
        sri.sales_receipt_total,
        sri.bill_address_id,
        sri.bill_address_line_1,
        sri.bill_address_line_2,
        sri.bill_address_line_3,
        sri.bill_address_line_4,
        sri.bill_address_line_5,
        sri.bill_address_city,
        sri.bill_address_country_sub_division_code,
        sri.bill_address_postal_code,
        sri.bill_address_lat,
        sri.bill_address_lon,
        sri.bill_email_address,
        sri.ship_address_id,
        sri.ship_address_line_1,
        sri.ship_address_line_2,
        sri.ship_address_line_3,
        sri.ship_address_line_4,
        sri.ship_address_line_5,
        sri.ship_address_city,
        sri.ship_address_country_sub_division_code,
        sri.ship_address_postal_code,
        sri.ship_address_lat,
        sri.ship_address_lon,
        sri.ship_method_ref_name,
        sri.ship_method_ref_value,
        sri.ship_method_ref_type,
        sri.ship_date,
        sri.department_ref_name,
        sri.department_ref_value,
        sri.department_ref_type,
        sri.payment_method_ref_name,
        sri.payment_method_ref_value,
        sri.payment_method_ref_type,
        sri.customer_ref_name,
        sri.customer_ref_value,
        sri.customer_ref_type,
        sri.balance,
        sri.payment_type,
        sri.currency_ref,
        sri.exchange_rate,
        sri.global_tax_calculation,
        sri.home_total_amount,
        sri.apply_after_tax_discount,
        sri.customer_memo,
        sri.private_note,
        sri.linked_transaction_id,
        sri.txn_tax_code_ref,
        sri.total_tax,
        NOW()
      FROM prediq_api_import_#{rails_env}.sales_receipt_imports sri
      JOIN prediq_api_#{rails_env}.api_address a ON a.customer_id = #{user_id} -- NOTE: Brian has created a new table for this so use that instead
      WHERE sri.api_customer_id = #{user_id}
      AND NOT EXISTS (SELECT api_customer_id FROM prediq_dw_#{rails_env}.d_sales_receipt
        WHERE
          api_customer_id     = sri.api_customer_id AND
          qb_sales_receipt_id = sri.qb_sales_receipt_id );"
    )

    # INSERT the the d_sales_receipt records into the fact table f_sales_total
    $dbconn.execute("
      -- NOTE: 'weather_stations_id' derived from the 'primary' address???  using the 'company_info.company_address' for now, but can update this
      -- when we load d_company_address IF a 'primary' address is indicated, which for now it is not
      INSERT INTO prediq_dw_#{rails_env}.f_sales_total (
	      transaction_date,
	      api_customer_id,
	      api_address_id,
	      weather_stations_id,
	      sales_total,
        created_at )
      SELECT
        dsr.date_key,
        dsr.api_customer_id,
        dsr.api_address_id,
        0,
        SUM(dsr.sales_receipt_total),
        NOW()
      FROM prediq_dw_#{rails_env}.d_sales_receipt dsr
      WHERE
        (dsr.api_customer_id = #{user_id} AND
        dsr.created_at >= DATE_SUB(CURDATE(),INTERVAL 2 DAY))
        AND NOT EXISTS (SELECT transaction_date FROM prediq_dw_#{rails_env}.f_sales_total
          WHERE
            transaction_date  = dsr.date_key 				AND
            api_customer_id   = dsr.api_customer_id AND
            api_address_id 	  = dsr.api_address_id )
      GROUP BY
        dsr.date_key,
          dsr.api_customer_id,
            dsr.api_address_id
      ORDER BY
        dsr.date_key,
          dsr.api_customer_id,
            dsr.api_address_id;" )
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
      meta_data_update_time:        company_info['meta_data']['last_updated_time'],
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
    #   first transaction date
    #   industry type
    #   company type
    #   Offering SKU
    #   subscription status
    #   payroll type
    #   accountant enabled
    }
  end

  def company_address_attribs(company_info, address_type, api_customer_id, qb_company_info_id)
    # %w( company comm legal)
    company_address  = company_info['company_address']
    comm_address          = company_info['customer_communication_address']
    legal_address         = company_info['legal_address']
    main                  = { address_type:       address_type,
                              api_customer_id:    api_customer_id,
                              qb_company_info_id: qb_company_info_id
                            }

    case address_type
      when 'company'
        addr_info = company_address
      when 'comm'
        addr_info = comm_address
      when 'legal'
        addr_info = legal_address
    end

    puts "***** addr_info['line1']: #{addr_info['line1']}";puts

    main.merge({
                   qb_company_address_id:      addr_info['id'],
                   weather_stations_id:        0,
                   line_1:                     (addr_info['line1']) ? addr_info['line1'].gsub( / *\n+/, ',' ) : nil,  # data like this: "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303" was truncing at the first \n
                   line_2:                     (addr_info['line2']) ? addr_info['line2'].gsub( / *\n+/, ',' ) : nil,
                   line_3:                     (addr_info['line3']) ? addr_info['line3'].gsub( / *\n+/, ',' ) : nil,
                   line_4:                     (addr_info['line4']) ? addr_info['line4'].gsub( / *\n+/, ',' ) : nil,
                   line_5:                     (addr_info['line5']) ? addr_info['line5'].gsub( / *\n+/, ',' ) : nil,
                   city:                       addr_info['city'],
                   country_sub_division_code:  addr_info['country_sub_division_code'],
                   postal_code:                addr_info['postal_code'],
                   lat:                        addr_info['lat'],
                   lon:                        addr_info['lon']
               })
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
    if sales_receipt['ship_method_ref']
      ship_method_ref        = sales_receipt['ship_method_ref']
      ship_method_ref_name   = (ship_method_ref['name'])  ? ship_method_ref['name']  : nil
      ship_method_ref_value  = (ship_method_ref['value']) ? ship_method_ref['value'] : nil
      ship_method_ref_type   = (ship_method_ref['type'])  ? ship_method_ref['type']  : nil
    else
      ship_method_ref_name, ship_method_ref_value, ship_method_ref_type = nil, nil, nil
    end
    if sales_receipt['payment_method_method_ref']
      payment_method_ref        = sales_receipt['payment_method_ref']
      payment_method_ref_name   = (payment_method_ref['name'])  ? payment_method_ref['name']  : nil
      payment_method_ref_value  = (payment_method_ref['value']) ? payment_method_ref['value'] : nil
      payment_method_ref_type   = (payment_method_ref['type'])  ? payment_method_ref['type']  : nil
    else
      payment_method_ref_name, payment_method_ref_value, payment_method_ref_type = nil, nil, nil
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
      meta_data_update_time:        sales_receipt['meta_data']['last_updated_time'],
      # last_updated_time
      transaction_date:             sales_receipt['txn_date'],
      # department_ref repeat like customer_ref, below
      customer_ref_name:            sales_receipt['customer_ref']['name'],
      customer_ref_value:           sales_receipt['customer_ref']['value'],
      customer_ref_type:            sales_receipt['customer_ref']['type'],
      bill_email_address:           (sales_receipt['bill_email']) ? sales_receipt['bill_email']['address'] : nil,
      # bill email (end user customer's email address)
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
      bill_address_line_1:          (bill_address['line1']) ? bill_address['line1'].gsub( / *\n+/, ',' ) : nil,  # data like this: "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303" was truncing at the first \n
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
      ship_address_line_1:          (ship_address_line_1) ? ship_address['line1'].gsub( / *\n+/, ',' ) : nil, # as above for bill_address_line_1
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
      ship_method_ref_name:         ship_method_ref_name,
      ship_method_ref_value:        ship_method_ref_value,
      ship_method_ref_type:         ship_method_ref_type,
      # shipping method
      ship_date:                    (sales_receipt['ship_date']) ? sales_receipt['ship_date']['date'] : nil,
      # ship date
      sales_receipt_total:          sales_receipt['total'],
      balance:                      (sales_receipt['balance']) ? sales_receipt['balance'] : nil,
      # balance
      payment_method_ref_name:      payment_method_ref_name,
      payment_method_ref_value:     payment_method_ref_value,
      payment_method_ref_type:      payment_method_ref_type,
      # payment ref method name, type, value
      payment_type:                 (sales_receipt['payment_type']) ? sales_receipt['payment_type'] : nil,
      # payment type
      apply_after_tax_discount:     (sales_receipt['apply_after_tax_discount']) ? sales_receipt['apply_after_tax_discount'] : nil,
      # apply_after_tax_discount
      currency_ref:                 (sales_receipt['currency_ref']) ? sales_receipt['currency_ref'] : nil,
      # currency_ref ??? the docs are unclear: https://developer.intuit.com/docs/api/accounting - NEED to see real data coming in
      exchange_rate:                (sales_receipt['currency_ref']) ? sales_receipt['currency_ref'] : nil,
      # exchange_rate
      global_tax_calculation:       (sales_receipt['global_tax_calculation']) ? sales_receipt['global_tax_calculation'] : nil,
      # global_tax_calculation
      home_total_amount:            (sales_receipt['home_total_amount']) ? sales_receipt['home_total_amount'] : nil,
      created_at:                   DateTime.now
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
        ship_address_id, ship_address_line_1, ship_address_line_2, ship_address_line_3, ship_address_line_4, ship_address_line_5, ship_address_city, ship_address_country_sub_division_code, ship_address_postal_code, ship_address_lat, ship_address_lon = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
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

  def create_sales_receipts_changes_temp_table
    $dbconn.execute("
      CREATE TEMPORARY TABLE sales_receipts_changes_temp (
      ID MEDIUMINT                  NOT NULL AUTO_INCREMENT,
      API_CUSTOMER_ID     INT(11)   NOT NULL,
      TRANSACTION_DATE    DATE      NOT NULL,
      BILL_ADDRESS_ID     INT(11)   NOT NULL,
      API_ADDRESS_ID      INT(11)   NOT NULL);")
  end

  def drop_sales_receipts_changes_temp_table
    $dbconn.execute("DROP TABLE sales_receipts_changes_temp;")
  end
end

# passed in arguments from the run_load_pg_data.sh script:
func            = ARGV[0] # will only execute if the ARGV[0] param exists and it is set to 'get_first_yr', 'get_five_yr' or 'get_daily'
rails_env       = ARGV[1] # import_development, import_staging, import_production, used to get the correct database.yml settings
current_path    = ARGV[2]
api_customer_id = ARGV[3]
address_types   = %w( company comm legal)


# To run the shell script that runs this job:
# NOTE: The process flow has us with an extant 'api_customer' record so we use that api_customer_id as the user_id to pass into
# the job.
# Local (existing api_customer user #9 that was created for testing):
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}
# Local (newly created/registered api_customer user #9):
# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr;rails_env=development;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}
# which then runs the following command that actually runs the job:
# RAILS_ENV=development bundle exec ruby app/classes/import_data.rb get_first_yr development /Users/billkiskin/prediq/prediq_api 2

if func == "get_first_yr"

  # NOTE: By the time this runs we already have an 'api_customer' user record created via the sign_up flow; now we
  # need to import the CustomerInfo into the DW via the customer_info_import table

  puts;puts "********* Running get_first_yr job; rails_env = #{rails_env}; api_customer_id = #{api_customer_id}";puts

  # 0. Instantiate the class
  id = ImportData.new( "Starting ImportData Job, func = '#{func}': #{Time.now}", rails_env, current_path, api_customer_id )

  user = UserImport.includes(:quickbooks_auth_import).find(api_customer_id)

  # 1.  Import the CompanyInfo data and split the address data into its import table
  qb_company_info_id = id.import_company_info_data(user)

  # ETL the company_info and address_info
  id.etl_company_info(user, qb_company_info_id, rails_env)

  # address_types.each do |address_type|
  #   puts "***** importing #{address_type}_address_info";puts
  #   # NOTE: we go through the motions of inserting into AddressInfoImport first then into d_company_address
  #   # in case we later need to do some transformations OR use data from AddressInfoImport for something in d_company_address,
  #   # such as calculating the nearest weather station
  #   AddressInfoImport.create!(company_address_attribs(company_info, address_type, user.id, qb_company_info_id))
  #   id.etl_address_info(user, qb_company_info_id, address_type)
  # end


  # 2. Import SalesReceipt data
  # Initial First Year import for the Sales Forecast
  # Calc the present date backwards one year for the query first year's sales receipt data

  # NOTE: tested OK so we comment it out for now
  query_date = (DateTime.now - 1.year).strftime('%Y-%m-%d')
  qb_entity = 'SalesReceipt'
  query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date}'"
  puts "********* query_str: #{query_str}"

  num_recs = id.import_sales_receipts(user, query_str)

  if num_recs > 0
    puts "#{func}: There were #{num_recs} #{qb_entity} records imported via: #{query_str}"
  else
    puts "#{func}: There were NO #{qb_entity} records imported via: #{query_str}"
  end


  # NOTE: For testing ONLY, we delete any prediq_rdev_#{rails_env}.D_SALES_RECEIPTS recs for our test user_id 9
  id.etl_sales_receipts(user, rails_env)

end

if func == "get_five_yr"
  # NOTE: Since this job will run later, probably at night after the "get_first_yr" job has been run contemporaneously,
  # we need to first check if the api_customer_id has F_SALES records at all, then get the MIN and MAX TxnDate
  # (TRANSACTION_DATE) to be able to make the appropriate 'query_date' to feed into the QB API query.

  puts;puts "********* Running get_five_yr job; rails_env = #{rails_env}; api_customer_id = #{api_customer_id}";puts

  # 1. Instantiate the class
  id = ImportData.new( "Starting ImportData Job, func = '#{func}': #{Time.now}", rails_env, current_path, api_customer_id )

  user = UserImport.includes(:quickbooks_auth_import).find(api_customer_id)

  # 2. Query the DW to get the MIN(TRANSACTION_DATE) from F_SALES to make the
  # Initial First Year import for the Sales Forecast
  # Calc the present date backwards one year for the query first year's sales receipt data query_date
  qb_entity = 'SalesReceipt'
  min_max_dates = $dbconn.select_all("SELECT MIN(TRANSACTION_DATE) as min_transaction_date, MAX(TRANSACTION_DATE) as max_transaction_date FROM prediq_rdev_#{$rails_env}.F_SALES WHERE API_CUSTOMER_ID = #{user.id}")[0]
  min_transaction_date, max_transaction_date, query_str = min_max_dates['min_transaction_date'], min_max_dates['max_transaction_date'], nil
  if min_transaction_date # we have F_SALES data for the customer
    # go back 5 years from from max_transaction_date UP TO min_transaction_date - 1 day to ensure contiguous, not overlapping date ranges.
    # ( as a fallback the insert into F_SALES_RECEIPT and F_SALES will not allow duplicates as defined by the unique compound keys )
    query_date_min = (Date.parse(max_transaction_date) - 5.year).strftime('%Y-%m-%d')
    query_date_max = (Date.parse(min_transaction_date) - 1.day).strftime('%Y-%m-%d')
    query_str      = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date_min}' AND TxnDate <= '#{query_date_max}'"
  else
    # min_transaction_date is nil so there is the chance that the 'get_first_year' job blew so we try for the full five years
    query_date_min = (Date.parse(max_transaction_date) - 5.year).strftime('%Y-%m-%d')
    query_str      = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date_min}'"
  end
  # 3. Import SalesReceipt data
  puts "********* query_str: #{query_str}"

  num_recs = id.import_sales_receipts(user, query_str)

  if num_recs > 0
    puts "#{func}: There were #{num_recs} #{qb_entity} records imported via: #{query_str}"
  else
    puts "#{func}: There were NO #{qb_entity} records imported via: '#{query_str}'"
  end

end

if func == "get_daily"
  # New data: get the MAX(TRANSACTION_DATE) for the F_SALES and select greater than that TxnDate and bring those in
  # "meta_data"=>{"create_time"=>2014-11-01 13:40:52 -0500, "last_updated_time"=>2014-11-01 13:40:52 -0500},

  puts;puts "********* Running get_daily_and_changes job; rails_env = #{rails_env}; api_customer_id = #{api_customer_id}";puts

  # 1. Instantiate the class
  id = ImportData.new( "Starting ImportData Job, func = '#{func}': #{Time.now}", rails_env, current_path, api_customer_id )

  user = UserImport.includes(:quickbooks_auth_import).find(api_customer_id)

  # New Data: get MAX(TRANSACTION_DATE) from F_SALES and select SalesReceipt recs > that date
  qb_entity = 'SalesReceipt'
  min_max_dates = $dbconn.select_all("SELECT MIN(TRANSACTION_DATE) as min_transaction_date, MAX(TRANSACTION_DATE) as max_transaction_date FROM prediq_rdev_#{$rails_env}.F_SALES WHERE API_CUSTOMER_ID = #{user.id}")[0]
  min_transaction_date, max_transaction_date, query_str = min_max_dates['min_transaction_date'], min_max_dates['max_transaction_date'], nil
  if max_transaction_date
    query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate > '#{max_transaction_date}'"
  else
    puts "There were NO new #{qb_entity} records for customer #{api_customer_id} that were greater than #{max_transaction_date}"
  end

  if query_str

    num_recs = id.import_sales_receipts(user, query_str)

    if num_recs > 0
      puts "#{func}: There were #{num_recs} #{qb_entity} records imported via: #{query_str}"
    else
      puts "#{func}: There were NO #{qb_entity} records imported via: '#{query_str}'"
    end

  end
end

# Working ON: get_changes
if func == "get_changes"
=begin
  Changed Data: where the "meta_data_last_updated_time" is different from the "meta_data_last_create_time",
  replace that record in D_SALES_RECEIPTS for that TxnDate, then update the F_SALES table for that TRANSACTION_DATE with
  the new aggregation from D_SALES_RECEIPTS for that TRANSACTION_DATE
  We could just go back one month and pick up every change.  This would involve processing the same record multiple times if,
  say, the change was yesterday,  so we go back 30 days and get that change, then the next day that change is now 2 days
  ago, so we get it again, and so on.  However, this will also encompass all other changes too, so this is a good strategy.
=end

=begin

************************************************************************************************************************
DESCRIPTION

  1). Get changed recs in the last 30 days, taking note of the meta_data_create_time so that we can get ALL the rest of the
  SalesReceipt recs for that data.  We must process that entire (TRANSACTION_DATE / API_CUSTOMER_ID / API_ADDRESS_ID)'s data
  all over again

  2). Then replace those records in D_SALES_RECEIPTS and finally, sum them via:

  dsr.DATE_KEY,
    dsr.API_CUSTOMER_ID_KEY,
      dsr.API_ADDRESS_ID_KEY

  Just like the initial F_SALES insert, and update that record in place in F_SALES

************************************************************************************************************************
PROCESS FLOW STEPS

  - For each quickbook_auths Customer, IF they have any D_SALES_RECEIPTS recs at all:
    - For each changed QB SalesReceipt rec in the last 30 days, store the:

    Store the TRANSACTION_DATE, API_CUSTOMER_ID, "bill_address"=>{"id"=>66...} in a temp table, one row per combo

    Table "SALES_RECEIPTS_CHANGES_TEMP"
      ID                  INT(11)
      API_CUSTOMER_ID     INT(11)   => passed in as the argument 'api_customer_id'
      TRANSACTION_DATE    date      => (from QB)
      BILL_ADDRESS_ID     INT(11)   => (from QB) "bill_address"=>{"id"=>66...}
      API_ADDRESS_ID      INT(11)   => use the 'BILL_ADDRESS_ID', above, to select the API_ADDRESS_ID from D_SALES_RECEIPTS,
                                    write from D_SALES_RECEIPTS.API_ADDRESS_ID.  This will be an INSERT with a JOIN
                                    to D_SALES_RECEIPTS on BILL_ADDRESS_ID (above) = (from QB) "bill_address"=>{"id"=>66...}

    Ruby iterate over this record set and get the set of SalesReceipt recs for that QB TRANSACTION_DATE, QB BILL_ADDRESS_ID ("bill_address"=>{"id"=>66...})
    Then:
      1. Delete the F_SALES recs via (TRANSACTION_DATE, API_CUSTOMER_ID, API_ADDRESS_ID)
          using: SALES_RECEIPTS_CHANGES_TEMP.TRANSACTION_DATE, SALES_RECEIPTS_CHANGES_TEMP.API_CUSTOMER_ID, SALES_RECEIPTS_CHANGES_TEMP.API_ADDRESS_ID
      2. Delete the D_SALES_RECEIPTS recs via (DATE_KEY, API_CUSTOMER_ID, API_ADDRESS_ID)
          using: SALES_RECEIPTS_CHANGES_TEMP.TRANSACTION_DATE, SALES_RECEIPTS_CHANGES_TEMP.API_CUSTOMER_ID, SALES_RECEIPTS_CHANGES_TEMP.API_ADDRESS_ID
      2. do "import_sales_receipts(user, query_str, batch_size)", with:
        qb_entity = 'SalesReceipt'
        query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate = '#{SALES_RECEIPTS_CHANGES_TEMP.TRANSACTION_DATE}'"
      3. do "def etl_sales_receipts(user, rails_env)"
      DONE

=end
  # 1). Get changed recs in the last 30 days


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
$ current_path=//var/www/vhosts/prediq_api/current;func=get_first_yr;rails_env=staging;api_customer_id=9; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_data.sh ${func} ${rails_env} ${current_path} ${api_customer_id}

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


OBSOLETE CODE:

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
  end

=end

=begin

  Split out the company info and the address info from the prediq_api_import_#{rails_env}.company_info_imports table
  #    and copy to the prediq_api_#{rails_env}.api_customer and the prediq_api_#{rails_env}.api_address tables, if the
  #    corresponding data is not already there.

  # 4. Check if they have any Invoices
  query_date = (DateTime.now - 1.year).strftime('%Y-%m-%d')
  qb_entity = 'Invoice'
  query_str = "SELECT * FROM #{qb_entity} WHERE TxnDate >= '#{query_date}'"

  id.import_invoices_data(user, query_str)


=end

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
=begin

  NOTE:  Since we are now doing this in PHP there is no need to import the company_info as the prediq_api_<rails_env>.api_customer
  record AND the prediq_api_<rails_env>.quickbook_auths records have already been created, so we do not need this part
  # was step 2. write the CompanyInfo data to the CompanyInfoImport relation
  id.import_company_info_data(user)
=end




