class CreateInvoiceLineItemImports < ActiveRecord::Migration
  def change
    create_table "prediq_api_import_#{Rails.env}.invoice_line_item_imports" do |t|
      t.integer  :api_customer_id
      t.integer  :qb_invoice_id
      t.integer :invoice_line_item_id  # {"id"=>1,
      t.integer :line_num
      t.string   :description
      t.string   :detail_type # SalesItemLineDetail or SubTotalLineDetail
      t.string   :sales_line_item_detail_item_ref_name
      t.string   :sales_line_item_detail_item_ref_value
      t.string   :sales_line_item_detail_item_ref_type
      t.decimal :sales_line_item_detail_unit_price, precision: 7, scale: 2
      t.decimal :sales_line_item_detail_quantity, precision: 7, scale: 2
      t.string  :sub_total_line_detail_item_ref_name
      t.string  :sub_total_line_detail_item_ref_value
      t.string  :sub_total_line_detail_item_ref_type
    end
  end
end
