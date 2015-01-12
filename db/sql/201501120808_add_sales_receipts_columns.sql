/*
  def sales_receipt_attribs(sales_receipt, api_customer_id)
    bill_address  = sales_receipt['bill_address']
    {
      api_customer_id:              api_customer_id,
      qb_sales_receipt_id:          sales_receipt['id'],
      sync_token:                   sales_receipt['sync_token'], # not needed
      meta_data_create_time:        sales_receipt['meta_data']['create_time'],
      # last_updated_time
      transaction_date:             sales_receipt['txn_date'],
      # department_ref repeat like customer_ref, below
      customer_ref_name:            sales_receipt['customer_ref']['name'],
      customer_ref_value:           sales_receipt['customer_ref']['value'],
      customer_ref_type:            sales_receipt['customer_ref']['type'],
      # customer_memo
      # private_note
      # linked_transaction_id
      # transaction tax code (object)
      bill_address_id:              bill_address['id'],
      bill_address_line_1:          bill_address['line1'],
      bill_address_line_2:          bill_address['line2'],
      bill_address_line_3:          bill_address['line3'],
      bill_address_line_4:          bill_address['line4'],
      bill_address_line_5:          bill_address['line5'],
      bill_address_city:            bill_address['city'],
      bill_address_country_sub_division_code: bill_address['country_sub_division_code'],
      bill_address_postal_code:     bill_address['postal_code'],
      bill_address_lat:             bill_address['lat'],
      bill_address_lon:             bill_address['lon'],
      # duplicate the above for ship_address info
      # shipping method
      # ship date
      sales_receipt_total:          sales_receipt['total']
      # bill email (end user customer's email address)
      # balance
      # payment ref method name, type, value
      # payment type
      # apply_after_tax_discount
      # currency_reference
      # exchange rate
      # global tax calc
      # home_total_amount
    }
  end


Working on:  left off at adding shipping_method
*/

ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN last_updated_time TIMESTAMP NULL AFTER meta_data_create_time;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN department_ref_name varchar(255) NULL AFTER customer_ref_type;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN department_ref_value INTEGER(11) NULL AFTER department_ref_name;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN department_ref_type varchar(255) NULL AFTER department_ref_value;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN customer_memo varchar(1024) NULL AFTER department_ref_name;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN private_note varchar(4096) NULL AFTER customer_memo;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN linked_transaction_id varchar(255) NULL AFTER private_note;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN txn_tax_code_ref varchar(255) NULL AFTER linked_transaction_id;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN total_tax DECIMAL(10, 4) NULL AFTER txn_tax_code_ref;

ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_id INTEGER(11) NULL AFTER bill_address_lon;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_line_1  varchar(255) NULL AFTER ship_address_id;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_line_2  varchar(255) NULL AFTER ship_address_line_1;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_line_3  varchar(255) NULL AFTER ship_address_line_2;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_line_4  varchar(255) NULL AFTER ship_address_line_3;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_line_5  varchar(255) NULL AFTER ship_address_line_4;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_city    varchar(255) NULL AFTER ship_address_line_5;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_country_sub_division_code varchar(255) NULL AFTER ship_address_city;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_postal_code varchar(255) NULL AFTER ship_address_country_sub_division_code;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_lat DECIMAL(10, 7) NULL AFTER ship_address_postal_code;
ALTER TABLE prediq_api_import_development.sales_receipt_imports ADD COLUMN ship_address_lon DECIMAL(10, 7) NULL AFTER ship_address_lat;






