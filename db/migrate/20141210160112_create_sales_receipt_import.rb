class CreateSalesReceiptImport < ActiveRecord::Migration

  # def connection
  #   ActiveRecord::Base.establish_connection("import_#{Rails.env}").connection
  # end

  def change
    create_table "prediq_api_import_#{Rails.env}.sales_receipt_imports" do |t|
      # NOTE: 'api_customer.customer_id' is the equivalent of the 'user_id'
      t.integer   :api_customer_id
      t.integer   :address_id
      t.integer   :qb_sales_receipt_id
      t.integer   :sync_token
      t.timestamp :transaction_date
      t.timestamp :meta_data_create_time
      t.decimal   :sales_receipt_total, precision: 7, scale: 2
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
    end
  end
end


=begin
Then to create the DB and run the migrations we must set the correct RAILS_ENV:

local machine:
$ RAILS_ENV=import_development bundle exec rake db:create
$ RAILS_ENV=development bundle exec rake db:migrate

staging server (after a deploy to get the new database.yml code up there):
$ RAILS_ENV=import_staging bundle exec rake db:create
$ RAILS_ENV=staging bundle exec rake db:migrate

rails g migration CreateSalesReceiptImport customer_id:integer address_id:integer qb_sales_receipt_id:integer transaction_date:timestamp meta_data_create_time:timestamp \
'sales_receipt_total:decimal{7,2}' customer_ref:string bill_address_id:integer customer_ref_name:string customer_ref_value:integer customer_ref_type:string \
bill_address_id:integer bill_address_line_1:string bill_address_line_2:string bill_address_line_3:string bill_address_line_4:string bill_address_line_5:string \
bill_address_city:string bill_address_country_sub_division_code:string bill_address_postal_code:string b'ill_address_lat:decimal{10,7}' 'bill_address_lon:decimal{10,7}'

=end
