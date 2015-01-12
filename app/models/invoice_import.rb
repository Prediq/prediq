# == Schema Information
#
# Table name: prediq_api_import_development.invoice_imports
#
#  address_id                             :integer
#  api_customer_id                        :integer
#  balance                                :decimal(8, 2)
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
#  customer_ref_name                      :string(255)
#  customer_ref_type                      :string(255)
#  customer_ref_value                     :integer
#  deposit                                :decimal(8, 2)
#  doc_number                             :integer
#  due_date                               :datetime
#  id                                     :integer          not null, primary key
#  meta_data_create_time                  :datetime
#  qb_invoice_id                          :integer
#  sales_term_ref_name                    :string(255)
#  sales_term_ref_type                    :string(255)
#  sales_term_ref_value                   :integer
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
#  sync_token                             :integer
#  total_amount                           :decimal(8, 2)
#  total_tax                              :decimal(7, 2)
#  transaction_date                       :datetime
#

class InvoiceImport < ActiveRecord::Base

  self.table_name = "prediq_api_import_#{Rails.env}.invoice_imports"

end
