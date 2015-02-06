# == Schema Information
#
# Table name: prediq_api_import_development.sales_receipt_imports
#
#  api_address_id                         :integer
#  api_customer_id                        :integer
#  apply_after_tax_discount               :boolean
#  balance                                :decimal(10, 2)
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
#  bill_email_address                     :string(255)
#  created_at                             :timestamp        not null
#  currency_ref                           :boolean
#  customer_memo                          :string(1024)
#  customer_ref_name                      :string(255)
#  customer_ref_type                      :string(255)
#  customer_ref_value                     :integer
#  department_ref_name                    :string(255)
#  department_ref_type                    :string(255)
#  department_ref_value                   :integer
#  exchange_rate                          :decimal(6, 2)
#  global_tax_calculation                 :string(255)
#  home_total_amount                      :decimal(10, 2)
#  id                                     :integer          not null, primary key
#  linked_transaction_id                  :string(255)
#  meta_data_create_time                  :datetime
#  meta_data_update_time                  :timestamp
#  payment_method_ref_name                :string(255)
#  payment_method_ref_type                :string(255)
#  payment_method_ref_value               :integer
#  payment_type                           :string(255)
#  private_note                           :string(4096)
#  qb_sales_receipt_id                    :integer
#  sales_receipt_total                    :decimal(10, 2)
#  ship_address_city                      :string(255)
#  ship_address_country_sub_division_code :string(255)
#  ship_address_id                        :integer
#  ship_address_lat                       :decimal(10, 7)
#  ship_address_line_1                    :string(255)
#  ship_address_line_2                    :string(255)
#  ship_address_line_3                    :string(255)
#  ship_address_line_4                    :string(255)
#  ship_address_line_5                    :string(255)
#  ship_address_lon                       :decimal(10, 7)
#  ship_address_postal_code               :string(255)
#  ship_date                              :timestamp
#  ship_method_ref_name                   :string(255)
#  ship_method_ref_type                   :string(255)
#  ship_method_ref_value                  :integer
#  sync_token                             :integer
#  total_tax                              :decimal(10, 4)
#  transaction_date                       :datetime
#  txn_tax_code_ref                       :string(255)
#

class SalesReceiptImport < ActiveRecord::Base

  self.table_name = "prediq_api_import_#{Rails.env}.sales_receipt_imports"

  # NOTE: Here so we can connect to its DB if we are running the app in development, staging, or production modes as a regular rails app
  # To use these for the standalone Ruby job we pass in the rails_env params as 'import_development', 'import_staging', 'production_import'
  # where we have already established a DB connection

  # establish_connection "import_#{Rails.env}" if ('development,staging,production').include?(Rails.env)

end
