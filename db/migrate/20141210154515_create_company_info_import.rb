class CreateCompanyInfoImport < ActiveRecord::Migration

  # def connection
  #   ActiveRecord::Base.establish_connection("import_#{Rails.env}").connection
  # end

  def change
    create_table "prediq_api_import_#{Rails.env}.company_info_imports" do |t|
      # NOTE: 'api_customer.customer_id' is the equivalent of the 'user_id'
      t.integer :api_customer_id
      t.integer :qb_company_info_id
      t.integer :sync_token
      t.timestamp :meta_data_create_time
      t.string :company_name
      t.string :legal_name
      t.integer :qb_company_address_id
      t.string  :qb_company_address_line_1
      t.string  :qb_company_address_line_2
      t.string  :qb_company_address_line_3
      t.string  :qb_company_address_line_4
      t.string  :qb_company_address_line_5
      t.string  :qb_company_address_city
      t.string  :qb_company_address_country_sub_division_code
      t.string  :qb_company_address_postal_code
      t.decimal :qb_company_address_lat, precision: 10, scale: 7
      t.decimal :qb_company_address_lon, precision: 10, scale: 7
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

rails g migration CreateCustomerInfoImport qb_company_info_id:integer sync_token:integer meta_data_create_time:timestamp company_name:string legal_name:string \
company_address_id:integer company_address_line_1:string company_address_line_2:string company_address_line_3:string company_address_line_4:string company_address_line_5:string \
company_address_city:string company_address_country_sub_division_code:string company_address_postal_code:string 'company_address_lat:decimal{10,7}' 'company_address_lon:decimal{10,7}' \
communication_address_id:integer communication_address_line_1:string communication_address_line_2:string communication_address_line_3:string communication_address_line_4:string communication_address_line_5:string \
communication_address_city:string communication_address_country_sub_division_code:string communication_address_postal_code:string 'communication_address_lat:decimal{10,7}' 'communication_address_lon:decimal{10,7}' \
legal_address_id:integer legal_address_line_1:string legal_address_line_2:string legal_address_line_3:string legal_address_line_4:string legal_address_line_5:string \
legal_address_city:string legal_address_country_sub_division_code:string legal_address_postal_code:string 'legal_address_lat:decimal{10,7}' 'legal_address_lon:decimal{10,7}' \
primary_phone:string company_start_date:timestamp fiscal_year_start_month:string country:string email:string
=end
