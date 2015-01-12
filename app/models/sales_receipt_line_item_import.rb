# == Schema Information
#
# Table name: prediq_api_import_development.line_item_imports
#
#  address_id              :integer
#  customer_id             :integer
#  description             :string(255)
#  detail_item_ref_name    :string(255)
#  detail_item_ref_type    :string(255)
#  detail_item_ref_value   :integer
#  detail_quantity         :decimal(7, 2)
#  detail_type             :string(255)
#  detail_unit_price       :decimal(7, 2)
#  id                      :integer          not null, primary key
#  line_num                :integer
#  linked_transactions     :string(255)
#  sales_receipt_import_id :integer
#  user_id                 :integer
#

class SalesReceiptLineItemImport < ActiveRecord::Base

  self.table_name = "prediq_api_import_#{Rails.env}.line_item_imports"

  # NOTE: Here so we can connect to its DB if we are running the app in development, staging, or production modes as a regular rails app
  # To use these for the standalone Ruby job we pass in the rails_env params as 'import_development', 'import_staging', 'production_import'
  # where we have already established a DB connection

  # establish_connection "import_#{Rails.env}" if ('development,staging,production').include?(Rails.env)

end
