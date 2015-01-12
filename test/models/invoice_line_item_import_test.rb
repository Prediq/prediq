# == Schema Information
#
# Table name: prediq_api_import_development.invoice_line_item_imports
#
#  api_customer_id                       :integer
#  description                           :string(255)
#  detail_type                           :string(255)
#  id                                    :integer          not null, primary key
#  invoice_line_item_id                  :integer
#  line_num                              :integer
#  qb_invoice_id                         :integer
#  sales_line_item_detail_item_ref_name  :string(255)
#  sales_line_item_detail_item_ref_type  :string(255)
#  sales_line_item_detail_item_ref_value :string(255)
#  sales_line_item_detail_quantity       :decimal(7, 2)
#  sales_line_item_detail_unit_price     :decimal(7, 2)
#  sub_total_line_detail_item_ref_name   :string(255)
#  sub_total_line_detail_item_ref_type   :string(255)
#  sub_total_line_detail_item_ref_value  :string(255)
#

require 'test_helper'

class InvoiceLineItemImportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
