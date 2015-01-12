# == Schema Information
#
# Table name: prediq_api_import_development.sales_receipt_imports
#
#  address_id                             :integer
#  api_customer_id                        :integer
#  bill_address_city                      :string(255)
#  bill_address_country_sub_division_code :string(255)
#  bill_address_id                        :integer
#  bill_address_lat                       :decimal(10, 7)
#  bill_address_line_1                    :string(255)
#  bill_address_line_2                    :string(255)
#  bill_address_line_3                    :string(255)
#  bill_address_line_4                    :string(255)
#  bill_address_line_5                    :string(255)
#  bill_address_lon                       :decimal(10, 7)
#  bill_address_postal_code               :string(255)
#  customer_ref_name                      :string(255)
#  customer_ref_type                      :string(255)
#  customer_ref_value                     :integer
#  id                                     :integer          not null, primary key
#  meta_data_create_time                  :datetime
#  qb_sales_receipt_id                    :integer
#  sales_receipt_total                    :decimal(7, 2)
#  sync_token                             :integer
#  transaction_date                       :datetime
#

class SalesReceiptImport < ActiveRecord::Base

  self.table_name = "prediq_api_import_#{Rails.env}.sales_receipt_imports"

  # NOTE: Here so we can connect to its DB if we are running the app in development, staging, or production modes as a regular rails app
  # To use these for the standalone Ruby job we pass in the rails_env params as 'import_development', 'import_staging', 'production_import'
  # where we have already established a DB connection

  # establish_connection "import_#{Rails.env}" if ('development,staging,production').include?(Rails.env)

end
