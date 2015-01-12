class CreateInvoiceImports < ActiveRecord::Migration
  def change
    create_table "prediq_api_import_#{Rails.env}.invoice_imports" do |t|
      # NOTE: 'api_customer.customer_id' is the equivalent of the 'user_id'
      t.integer     :api_customer_id
      t.integer     :address_id
      t.integer     :qb_invoice_id
      t.integer     :sync_token
      t.timestamp   :meta_data_create_time
      t.integer     :doc_number
      t.timestamp   :transaction_date
      t.decimal     :total_tax, precision: 7, scale: 2                    # txn_tax_detail_total_tax
      t.string      :customer_ref_name
      t.integer     :customer_ref_value
      t.string      :customer_ref_type
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
    end
  end
end
