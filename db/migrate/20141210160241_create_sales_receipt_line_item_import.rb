class CreateSalesReceiptLineItemImport < ActiveRecord::Migration

  def change
    create_table "prediq_api_import_#{Rails.env}.sales_receipt_line_item_imports" do |t|
      # NOTE: 'api_customer.customer_id' is the equivalent of the 'user_id'
      t.integer  :api_customer_id
      t.integer :sales_receipt_import_id
      t.integer :customer_id
      t.integer :address_id
      t.integer :line_num
      t.string :detail_type
      t.string :description
      t.string :linked_transactions
      t.string :detail_item_ref_name
      t.integer :detail_item_ref_value
      t.string :detail_item_ref_type
      t.decimal :detail_unit_price, precision: 7, scale: 2
      t.decimal :detail_quantity, precision: 7, scale: 2
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


rails g migration CreateLineItemImport sales_receipt_import_id:integer customer_id:integer address_id:integer line_num:integer detail_type:string description:string \
linked_transactions:string detail_item_ref_name:string detail_item_ref_value:integer detail_item_ref_type:string 'detail_unit_price:decimal{7,2}' 'detail_quantity:decimal{7,2}'
=end
