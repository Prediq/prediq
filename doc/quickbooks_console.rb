user = User.includes(:user_addresses).find 2
company_info = QuickbooksCommunicator.new(user.quickbooks_auth).company_info
sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth).sales_receipts
invoices = QuickbooksCommunicator.new(user.quickbooks_auth_import).invoices

sales_receipts.each do |sales_receipt|
  puts "****** meta_data.create_time: #{sales_receipt.meta_data.create_time}"
  puts "****** txn_date: #{sales_receipt.txn_date}"
  puts "****** sales_receipt.total: #{sales_receipt.total}"
  puts "********** LINE ITEMS:"
  sales_receipt.line_items.each do |line_item|
    puts "************ detail_type: #{line_item.detail_type}"
    if line_item.detail_type == 'SalesItemLineDetail'
      puts "************ line_num: #{line_item.line_num}"
      puts "************ description: #{line_item.description}"
    end
    puts "************ amount: #{line_item.amount}"
  end
end

=begin

https://developer.intuit.com/docs/api/accounting

****** meta_data.create_time: 2014-11-01 13:40:52 -0500
****** txn_date: 2014-10-30 00:00:00 -0500
****** sales_receipt.total: 140.0
********** LINE ITEMS:
************ detail_type: SalesItemLineDetail
************ line_num: 1
************ description: Weekly Gardening Service
************ amount: 140.0
************ detail_type: SubTotalLineDetail
************ amount: 140.0
****** meta_data.create_time: 2014-11-01 13:15:46 -0500
****** txn_date: 2014-11-01 00:00:00 -0500
****** sales_receipt.total: 78.75
********** LINE ITEMS:
************ detail_type: SalesItemLineDetail
************ line_num: 1
************ description: Pest Control Services
************ amount: 87.5
************ detail_type: SubTotalLineDetail
************ amount: 87.5
************ detail_type: DiscountLineDetail
************ amount: 8.75
****** meta_data.create_time: 2014-10-31 17:12:39 -0500
****** txn_date: 2014-10-09 00:00:00 -0500
****** sales_receipt.total: 225.0
********** LINE ITEMS:
************ detail_type: SalesItemLineDetail
************ line_num: 1
************ description: Custom Design
************ amount: 225.0
************ detail_type: SubTotalLineDetail
************ amount: 225.0
****** meta_data.create_time: 2014-10-31 16:59:48 -0500
****** txn_date: 2014-10-29 00:00:00 -0500
****** sales_receipt.total: 337.5
********** LINE ITEMS:
************ detail_type: SalesItemLineDetail
************ line_num: 1
************ description: Custom Design
************ amount: 337.5
************ detail_type: SubTotalLineDetail
************ amount: 337.5

=end


=begin
To get quickbooks data at the console:

1. In a browser log in as user 2 "tc2@bigmagma.com" authenticate QB to create the user and create the QuickbooksAuth
record for that user so we can next hit QB for the data
  a. dashboard page, click Connect to QB as you can use wes@prediq.com pr3d1q

2. In console
  a. user = User.find 2
  b. sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth_import).sales_receipts
  c. sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth_import).sales_receipts("SELECT * FROM SalesReceipt WHERE TxnDate >= '2014-10-30'")
  d. company_info = QuickbooksCommunicator.new(user.quickbooks_auth_import).company_info
  d. invoices = QuickbooksCommunicator.new(user.quickbooks_auth_import).invoices

************************************************************************************************************************
Company Information

4] pry(main)> company_info = QuickbooksCommunicator.new(user.quickbooks_auth).company_info
=> #<Quickbooks::Collection:0x007fecdc3d1fc8
 @count=1,
 @entries=
  [#<Quickbooks::Model::CompanyInfo id: 1, sync_token: 6, meta_data: {"create_time"=>2014-10-20 05:35:32 -0500, "last_updated_time"=>2014-11-29 06:06:29 -0600}, company_name: Wesley Robinson Sandbox Company, legal_name: Wesley Robinson Sandbox Company, company_address: {"id"=>1, "line1"=>"123 Sierra Way", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"San Pablo", "country"=>nil, "country_sub_division_code"=>"CA", "postal_code"=>"87999", "note"=>nil, "lat"=>"36.6788345", "lon"=>"-5.4464622"}, customer_communication_address: {"id"=>1, "line1"=>"123 Sierra Way", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"San Pablo", "country"=>nil, "country_sub_division_code"=>"CA", "postal_code"=>"87999", "note"=>nil, "lat"=>"36.6788345", "lon"=>"-5.4464622"}, legal_address: {"id"=>1, "line1"=>"123 Sierra Way", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"San Pablo", "country"=>nil, "country_sub_division_code"=>"CA", "postal_code"=>"87999", "note"=>nil, "lat"=>"36.6788345", "lon"=>"-5.4464622"}, primary_phone: {"free_form_number"=>nil}, company_start_date: 2014-10-20T00:00:00+00:00, employer_id: nil, fiscal_year_start_month: January, country: US, email: {"address"=>"noreply@quickbooks.com"}, web_site: {"uri"=>nil}, supported_languages: en>],
 @max_results=1>

[6] pry(main)> company_info.first.attributes
=> {"id"=>1, qb_company_info_id
 "sync_token"=>6,
 "meta_data"=>{"create_time"=>2014-10-20 05:35:32 -0500, "last_updated_time"=>2014-11-29 06:06:29 -0600},
 "company_name"=>"Wesley Robinson Sandbox Company",
 "legal_name"=>"Wesley Robinson Sandbox Company",
 "company_address"=>
  {"id"=>1,  qb_company_address_id
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "customer_communication_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "legal_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "primary_phone"=>{"free_form_number"=>nil},
 "company_start_date"=>Mon, 20 Oct 2014 00:00:00 +0000,
 "employer_id"=>nil,
 "fiscal_year_start_month"=>"January",
 "country"=>"US",
 "email"=>{"address"=>"noreply@quickbooks.com"},
 "web_site"=>{"uri"=>nil},
 "supported_languages"=>"en"}

************************************************************************************************************************

  c. the array = sales_receipts.entries

[6] pry(main)> sales_receipts.first.attributes
=> {"global_tax_calculation"=>nil,
 "id"=>47,
 "sync_token"=>0,
 "meta_data"=>{"create_time"=>2014-11-01 13:40:52 -0500, "last_updated_time"=>2014-11-01 13:40:52 -0500},
 "auto_doc_number"=>nil,
 "doc_number"=>"1014",
 "txn_date"=>2014-10-30 00:00:00 -0500,
 "line_items"=>
  [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Weekly Gardening Service, amount: 140.0, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>,
   #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 140.0, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>],
 "customer_ref"=>{"name"=>"Diego Rodriguez", "value"=>"4", "type"=>nil},
 "bill_email"=>{"address"=>"Diego@Rodriguez.com"},
 "bill_address"=>
  {"id"=>66,
   "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>nil,
   "country"=>nil,
   "country_sub_division_code"=>nil,
   "postal_code"=>nil,
   "note"=>nil,
   "lat"=>"37.4530553",
   "lon"=>"-122.1178261"},
 "ship_address"=>nil,
 "po_number"=>nil,
 "ship_method_ref"=>nil,
 "ship_date"=>nil,
 "tracking_num"=>nil,
 "payment_method_ref"=>nil,
 "payment_ref_number"=>nil,
 "deposit_to_account_ref"=>{"name"=>"Undeposited Funds", "value"=>"4", "type"=>nil},
 "customer_memo"=>"Thank you for your business and have a great day!",
 "private_note"=>nil,
 "total"=>#<BigDecimal:7fb0734ed7e0,'0.14E3',9(18)>}

[7] pry(main)> sales_receipts.first.line_items
=> [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Weekly Gardening Service, amount: 140.0, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>,
 #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 140.0, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>]

[9] pry(main)> sales_receipts.first.line_items.first.attributes
=> {"id"=>1,
 "line_num"=>1,
 "description"=>"Weekly Gardening Service",
 "amount"=>#<BigDecimal:7fb0735bee30,'0.14E3',9(18)>,
 "detail_type"=>"SalesItemLineDetail",
 "linked_transactions"=>[],
 "sales_item_line_detail"=>
  {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil},
   "class_ref"=>nil,
   "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>,
   "rate_percent"=>nil,
   "price_level_ref"=>nil,
   "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>,
   "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil},
   "service_date"=>nil},
 "sub_total_line_detail"=>nil,
 "payment_line_detail"=>nil,
 "discount_line_detail"=>nil,
 "journal_entry_line_detail"=>nil}

************************************************************************************************************************

[1] pry(main)> user = User.find 2
  User Load (0.2ms)  SELECT  `api_customer`.* FROM `api_customer`  WHERE `api_customer`.`customer_id` = 2 LIMIT 1
=> #<User customer_id: 2, store_id: 0, firstname: "Indianapolis", lastname: "FastFood", email: "tc2@bigmagma.com", telephone: "12345677889", fax: "", encrypted_password: "$2a$10$yLQNfa3k1nQF87zB7yM.Qu4NtEGZ6BfryE6aoNK3KxW...", salt: "f990b9a43", api_key: "bbc042e2011fbf9b9fc10a96d2f9b8x2", newsletter: true, address_id: 2, customer_group_id: 1, ip: "70.116.134.54", status: true, approved: true, token: "w4t34543twdvsREQTE634Q61BDASVVZwareyqtyqrety5454", date_added: "2014-03-11 15:48:28", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2014-12-08 17:18:22", last_sign_in_at: "2014-12-08 17:18:22", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", created_at: nil, updated_at: "2014-12-08 17:18:22">
[2] pry(main)> sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth).sales_receipts
  QuickbooksAuth Load (0.3ms)  SELECT  `quickbooks_auths`.* FROM `quickbooks_auths`  WHERE `quickbooks_auths`.`user_id` = 2 LIMIT 1
=> #<Quickbooks::Collection:0x007fb0729ed0c0
 @count=4,
 @entries=
  [#<Quickbooks::Model::SalesReceipt global_tax_calculation: nil, id: 47, sync_token: 0, meta_data: {"create_time"=>2014-11-01 13:40:52 -0500, "last_updated_time"=>2014-11-01 13:40:52 -0500}, auto_doc_number: nil, doc_number: 1014, txn_date: 2014-10-30 00:00:00 -0500, line_items: [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Weekly Gardening Service, amount: 140.0, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>, #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 140.0, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>], customer_ref: {"name"=>"Diego Rodriguez", "value"=>"4", "type"=>nil}, bill_email: {"address"=>"Diego@Rodriguez.com"}, bill_address: {"id"=>66, "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>nil, "country"=>nil, "country_sub_division_code"=>nil, "postal_code"=>nil, "note"=>nil, "lat"=>"37.4530553", "lon"=>"-122.1178261"}, ship_address: nil, po_number: nil, ship_method_ref: nil, ship_date: nil, tracking_num: nil, payment_method_ref: nil, payment_ref_number: nil, deposit_to_account_ref: {"name"=>"Undeposited Funds", "value"=>"4", "type"=>nil}, customer_memo: Thank you for your business and have a great day!, private_note: nil, total: 140.0>,
   #<Quickbooks::Model::SalesReceipt global_tax_calculation: nil, id: 38, sync_token: 0, meta_data: {"create_time"=>2014-11-01 13:15:46 -0500, "last_updated_time"=>2014-11-01 13:15:46 -0500}, auto_doc_number: nil, doc_number: 1011, txn_date: 2014-11-01 00:00:00 -0500, line_items: [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Pest Control Services, amount: 87.5, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Pest Control", "value"=>"10", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb071a9a938,'0.35E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb070b485c0,'0.25E1',18(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>, #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 87.5, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>, #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 8.75, detail_type: DiscountLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: {"discount_ref"=>nil, "percent_based?"=>true, "discount_percent"=>#<BigDecimal:7fb072977050,'0.1E2',9(18)>, "discount_account_ref"=>{"name"=>"Discounts given", "value"=>"86", "type"=>nil}}, journal_entry_line_detail: nil>], customer_ref: {"name"=>"Pye's Cakes", "value"=>"15", "type"=>nil}, bill_email: {"address"=>"karen@pye.com"}, bill_address: {"id"=>57, "line1"=>"Karen Pye\nPye's Cakes\n350 Mountain View Dr.\nSouth Orange, NJ  07079", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>nil, "country"=>nil, "country_sub_division_code"=>nil, "postal_code"=>nil, "note"=>nil, "lat"=>"40.7489277", "lon"=>"-74.2609903"}, ship_address: {"id"=>15, "line1"=>"350 Mountain View Dr.", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"South Orange", "country"=>nil, "country_sub_division_code"=>"NJ", "postal_code"=>"07079", "note"=>nil, "lat"=>"40.7633073", "lon"=>"-74.2426072"}, po_number: nil, ship_method_ref: nil, ship_date: nil, tracking_num: nil, payment_method_ref: {"name"=>"Cash", "value"=>"1", "type"=>nil}, payment_ref_number: nil, deposit_to_account_ref: {"name"=>"Undeposited Funds", "value"=>"4", "type"=>nil}, customer_memo: Thank you for your business and have a great day!, private_note: nil, total: 78.75>,
   #<Quickbooks::Model::SalesReceipt global_tax_calculation: nil, id: 17, sync_token: 0, meta_data: {"create_time"=>2014-10-31 17:12:39 -0500, "last_updated_time"=>2014-10-31 17:12:39 -0500}, auto_doc_number: nil, doc_number: 1008, txn_date: 2014-10-09 00:00:00 -0500, line_items: [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Custom Design, amount: 225.0, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Design", "value"=>"4", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb0728e6208,'0.75E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb0709604b0,'0.3E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>, #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 225.0, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>], customer_ref: {"name"=>"Kate Whelan", "value"=>"14", "type"=>nil}, bill_email: {"address"=>"Kate@Whelan.com"}, bill_address: {"id"=>54, "line1"=>"Kate Whelan\n45 First St.\nMenlo Park, CA  94304 USA", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>nil, "country"=>nil, "country_sub_division_code"=>nil, "postal_code"=>nil, "note"=>nil, "lat"=>"37.3813444", "lon"=>"-122.1802812"}, ship_address: {"id"=>14, "line1"=>"45 First St.", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"Menlo Park", "country"=>"USA", "country_sub_division_code"=>"CA", "postal_code"=>"94304", "note"=>nil, "lat"=>"37.4585825", "lon"=>"-122.1352789"}, po_number: nil, ship_method_ref: nil, ship_date: nil, tracking_num: nil, payment_method_ref: nil, payment_ref_number: nil, deposit_to_account_ref: {"name"=>"Checking", "value"=>"35", "type"=>nil}, customer_memo: Thank you for your business and have a great day!, private_note: nil, total: 225.0>,
   #<Quickbooks::Model::SalesReceipt global_tax_calculation: nil, id: 11, sync_token: 0, meta_data: {"create_time"=>2014-10-31 16:59:48 -0500, "last_updated_time"=>2014-10-31 16:59:48 -0500}, auto_doc_number: nil, doc_number: 1003, txn_date: 2014-10-29 00:00:00 -0500, line_items: [#<Quickbooks::Model::Line id: 1, line_num: 1, description: Custom Design, amount: 337.5, detail_type: SalesItemLineDetail, linked_transactions: [], sales_item_line_detail: {"item_ref"=>{"name"=>"Design", "value"=>"4", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fb071ea5cf8,'0.75E2',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fb071eaf398,'0.45E1',18(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>, #<Quickbooks::Model::Line id: nil, line_num: nil, description: nil, amount: 337.5, detail_type: SubTotalLineDetail, linked_transactions: [], sales_item_line_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil, journal_entry_line_detail: nil>], customer_ref: {"name"=>"Dylan Sollfrank", "value"=>"6", "type"=>nil}, bill_email: nil, bill_address: {"id"=>49, "line1"=>"Dylan Sollfrank", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>nil, "country"=>nil, "country_sub_division_code"=>nil, "postal_code"=>nil, "note"=>nil, "lat"=>"INVALID", "lon"=>"INVALID"}, ship_address: nil, po_number: nil, ship_method_ref: nil, ship_date: nil, tracking_num: nil, payment_method_ref: {"name"=>"Check", "value"=>"2", "type"=>nil}, payment_ref_number: 10264, deposit_to_account_ref: {"name"=>"Checking", "value"=>"35", "type"=>nil}, customer_memo: Thank you for your business and have a great day!, private_note: nil, total: 337.5>],
 @max_results=4,
 @start_position=1>

=end

=begin


NOTE: Before running these migrations we need to ensure that the schema "import" exists

Williams-MacBook-Pro ~/prediq/prediq_api: mysql -u root -d prediq_api_development
create database import CHARACTER SET utf8 COLLATE utf8_general_ci;
alter table old_db.fooTable rename new_db.fooTable

We have entries in the database.yml for:

 RAILS_ENV=import_development
 RAILS_ENV=import_staging

Then to create the DB we must set the correct RAILS_ENV for the :

local machine:
$ RAILS_ENV=import_development bundle exec rake db:create
Migrations are handled normally because we have this in each migration file that needs to be in the
prediq_api_import_development DB:

  def connection
    ActiveRecord::Base.establish_connection("import_#{Rails.env}").connection
  end
 and the database.yml has entries for the 'other' DB:

import_development:
  <<: *default
  database: prediq_api_import_development


staging server (after a deploy to get the new database.yml code up there):
$ RAILS_ENV=import_staging bundle exec rake db:create
Migrations are handled as above


rails g migration CreateCustomerInfoImport sync_token:integer meta_data_create_time:timestamp company_name:string legal_name:string \
company_address_id:integer company_address_line_1:string company_address_line_2:string company_address_line_3:string company_address_line_4:string company_address_line_5:string \
company_address_city:string company_address_country_sub_division_code:string company_address_postal_code:string 'company_address_lat:decimal{10,7}' 'company_address_lon:decimal{10,7}' \
communication_address_id:integer communication_address_line_1:string communication_address_line_2:string communication_address_line_3:string communication_address_line_4:string communication_address_line_5:string \
communication_address_city:string communication_address_country_sub_division_code:string communication_address_postal_code:string 'communication_address_lat:decimal{10,7}' 'communication_address_lon:decimal{10,7}' \
legal_address_id:integer legal_address_line_1:string legal_address_line_2:string legal_address_line_3:string legal_address_line_4:string legal_address_line_5:string \
legal_address_city:string legal_address_country_sub_division_code:string legal_address_postal_code:string 'legal_address_lat:decimal{10,7}' 'legal_address_lon:decimal{10,7}' \
primary_phone:string company_start_date:timestamp fiscal_year_start_month:string country:string email:string

rails g migration CreateSalesReceiptImport customer_id:integer address_id:integer transaction_date:timestamp meta_data_create_time:timestamp \
'sales_receipt_total:decimal{7,2}' customer_ref:string bill_address_id:integer customer_ref_name:string customer_ref_value:integer customer_ref_type:string \
bill_address_id:integer bill_address_line_1:string bill_address_line_2:string bill_address_line_3:string bill_address_line_4:string bill_address_line_5:string \
bill_address_city:string bill_address_country_sub_division_code:string bill_address_postal_code:string b'ill_address_lat:decimal{10,7}' 'bill_address_lon:decimal{10,7}'

rails g migration CreateLineItemImport sales_receipt_import_id:integer customer_id:integer address_id:integer line_num:integer detail_type:string description:string \
linked_transactions:string detail_item_ref_name:string detail_item_ref_value:integer detail_item_ref_type:string 'detail_unit_price:decimal{7,2}' 'detail_quantity:decimal{7,2}'

[6] pry(main)> company_info.first.attributes
=> {"id"=>1,
 "sync_token"=>6,
 "meta_data"=>{"create_time"=>2014-10-20 05:35:32 -0500, "last_updated_time"=>2014-11-29 06:06:29 -0600},
 "company_name"=>"Wesley Robinson Sandbox Company",
 "legal_name"=>"Wesley Robinson Sandbox Company",
 "company_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "customer_communication_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "legal_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},
 "primary_phone"=>{"free_form_number"=>nil},
 "company_start_date"=>Mon, 20 Oct 2014 00:00:00 +0000,
 "employer_id"=>nil,
 "fiscal_year_start_month"=>"January",
 "country"=>"US",
 "email"=>{"address"=>"noreply@quickbooks.com"},
 "web_site"=>{"uri"=>nil},
 "supported_languages"=>"en"}



 "sales_item_line_detail"=>
  {"item_ref"=>{"name"=>"Gardening", "value"=>"6", "type"=>nil},
   "class_ref"=>nil,
   "unit_price"=>#<BigDecimal:7fb073595fa8,'0.35E2',9(18)>,
   "rate_percent"=>nil,
   "price_level_ref"=>nil,
   "quantity"=>#<BigDecimal:7fb073587e58,'0.4E1',9(18)>,
   "tax_code_ref"=>{"name"=>nil, "value"=>"NON", "type"=>nil},

 "bill_email"=>{"address"=>"Diego@Rodriguez.com"},
 "bill_address"=>
  {"id"=>66,
   "line1"=>"Diego Rodriguez\n321 Channing\nPalo Alto, CA  94303",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>nil,
   "country"=>nil,
   "country_sub_division_code"=>nil,
   "postal_code"=>nil,
   "note"=>nil,
   "lat"=>"37.4530553",
   "lon"=>"-122.1178261"},

"customer_ref"=>{"name"=>"Diego Rodriguez", "value"=>"4", "type"=>nil}


[4] pry(main)> invoice.attributes
=> {"global_tax_calculation"=>nil,
 "id"=>130,
 "sync_token"=>0,
 "meta_data"=>{"create_time"=>2014-11-03 15:16:17 -0600, "last_updated_time"=>2014-11-03 15:16:17 -0600},
 "custom_fields"=>[#<Quickbooks::Model::CustomField id: 1, name: Crew #, type: StringType, string_value: 102, boolean_value: nil, date_value: nil, number_value: nil>],
 "auto_doc_number"=>nil,
 "doc_number"=>"1037",
 "txn_date"=>Mon, 03 Nov 2014,
 "currency_ref"=>nil,
 "exchange_rate"=>nil,
 "private_note"=>nil,
 "linked_transactions"=>[#<Quickbooks::Model::LinkedTransaction txn_id: 100, txn_type: Estimate, txn_line_id: nil>],
 "lineline_items"=>
  [#<Quickbooks::Model::InvoiceLineItem id: 1, line_num: 1, description: Rock Fountain, amount: 275.0, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2dc340,'0.275E3',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45d3e18f0,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: 2, line_num: 2, description: Fountain Pump, amount: 12.75, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Pump", "value"=>"11", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45c9eacc0,'0.1275E2',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45c9d9010,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: 3, line_num: 3, description: Concrete for fountain installation, amount: 47.5, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Concrete", "value"=>"3", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2bf650,'0.95E1',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45b1a7780,'0.5E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
   #<Quickbooks::Model::InvoiceLineItem id: nil, line_num: nil, description: nil, amount: 335.25, detail_type: SubTotalLineDetail, sales_line_item_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil>],
 "txn_tax_detail"=>
  {"txn_tax_code_ref"=>{"name"=>nil, "value"=>"2", "type"=>nil},
   "total_tax"=>#<BigDecimal:7fa45c938b38,'0.2682E2',18(18)>,
   "lines"=>
    [#<Quickbooks::Model::TaxLine id: nil, line_num: nil, description: nil, amount: 26.82, detail_type: TaxLineDetail, tax_line_detail: {"percent_based?"=>true, "net_amount_taxable"=>#<BigDecimal:7fa45a26ed90,'0.33525E3',18(18)>, "tax_inclusive_amount"=>nil, "override_delta_amount"=>nil, "tax_percent"=>#<BigDecimal:7fa45a244608,'0.8E1',9(18)>, "tax_rate_ref"=>{"name"=>nil, "value"=>"3", "type"=>nil}}>]},
 "customer_ref"=>{"name"=>"Sonnenschein Family Store", "value"=>"24", "type"=>nil},
 "customer_memo"=>"Thank you for your business and have a great day!",
 "billing_address"=>
  {"id"=>95,
   "line1"=>"Russ Sonnenschein\nSonnenschein Family Store\n5647 Cypress Hill Ave.\nMiddlefield, CA  94303",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>nil,
   "country"=>nil,
   "country_sub_division_code"=>nil,
   "postal_code"=>nil,
   "note"=>nil,
   "lat"=>"37.4238562",
   "lon"=>"-122.1141681"},
 "shipping_address"=>
  {"id"=>25,
   "line1"=>"5647 Cypress Hill Ave.",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"Middlefield",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"94303",
   "note"=>nil,
   "lat"=>"37.4238562",
   "lon"=>"-122.1141681"},
 "class_ref"=>nil,
 "sales_term_ref"=>{"name"=>nil, "value"=>"3", "type"=>nil},
 "due_date"=>Wed, 03 Dec 2014,
 "ship_method_ref"=>nil,
 "ship_date"=>nil,
 "tracking_num"=>nil,
 "ar_account_ref"=>nil,
 "total_amount"=>#<BigDecimal:7fa45d255658,'0.36207E3',18(18)>,
 "home_total_amount"=>nil,
 "apply_tax_after_discount?"=>false,
 "print_status"=>"NeedToPrint",
 "email_status"=>"NotSet",
 "balance"=>#<BigDecimal:7fa45d1988a0,'0.36207E3',18(18)>,
 "deposit"=>#<BigDecimal:7fa45d15bae0,'0.0',9(18)>,
 "department_ref"=>nil,
 "allow_ipn_payment?"=>false,
 "bill_email"=>{"address"=>"Familiystore@intuit.com"},
 "allow_online_payment?"=>false,
 "allow_online_credit_card_payment?"=>false,
 "allow_online_ach_payment?"=>false}

[3] pry(main)> invoice = invoices.first
=> #<Quickbooks::Model::Invoice global_tax_calculation: nil, id: 130, sync_token: 0, meta_data: {"create_time"=>2014-11-03 15:16:17 -0600, "last_updated_time"=>2014-11-03 15:16:17 -0600}, custom_fields: [#<Quickbooks::Model::CustomField id: 1, name: Crew #, type: StringType, string_value: 102, boolean_value: nil, date_value: nil, number_value: nil>], auto_doc_number: nil, doc_number: 1037, txn_date: 2014-11-03, currency_ref: nil, exchange_rate: nil, private_note: nil, linked_transactions: [#<Quickbooks::Model::LinkedTransaction txn_id: 100, txn_type: Estimate, txn_line_id: nil>], line_items: [#<Quickbooks::Model::InvoiceLineItem id: 1, line_num: 1, description: Rock Fountain, amount: 275.0, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2dc340,'0.275E3',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45d3e18f0,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>, #<Quickbooks::Model::InvoiceLineItem id: 2, line_num: 2, description: Fountain Pump, amount: 12.75, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Pump", "value"=>"11", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45c9eacc0,'0.1275E2',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45c9d9010,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>, #<Quickbooks::Model::InvoiceLineItem id: 3, line_num: 3, description: Concrete for fountain installation, amount: 47.5, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Concrete", "value"=>"3", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2bf650,'0.95E1',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45b1a7780,'0.5E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>, #<Quickbooks::Model::InvoiceLineItem id: nil, line_num: nil, description: nil, amount: 335.25, detail_type: SubTotalLineDetail, sales_line_item_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil>], txn_tax_detail: {"txn_tax_code_ref"=>{"name"=>nil, "value"=>"2", "type"=>nil}, "total_tax"=>#<BigDecimal:7fa45c938b38,'0.2682E2',18(18)>, "lines"=>[#<Quickbooks::Model::TaxLine id: nil, line_num: nil, description: nil, amount: 26.82, detail_type: TaxLineDetail, tax_line_detail: {"percent_based?"=>true, "net_amount_taxable"=>#<BigDecimal:7fa45a26ed90,'0.33525E3',18(18)>, "tax_inclusive_amount"=>nil, "override_delta_amount"=>nil, "tax_percent"=>#<BigDecimal:7fa45a244608,'0.8E1',9(18)>, "tax_rate_ref"=>{"name"=>nil, "value"=>"3", "type"=>nil}}>]}, customer_ref: {"name"=>"Sonnenschein Family Store", "value"=>"24", "type"=>nil}, customer_memo: Thank you for your business and have a great day!, billing_address: {"id"=>95, "line1"=>"Russ Sonnenschein\nSonnenschein Family Store\n5647 Cypress Hill Ave.\nMiddlefield, CA  94303", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>nil, "country"=>nil, "country_sub_division_code"=>nil, "postal_code"=>nil, "note"=>nil, "lat"=>"37.4238562", "lon"=>"-122.1141681"}, shipping_address: {"id"=>25, "line1"=>"5647 Cypress Hill Ave.", "line2"=>nil, "line3"=>nil, "line4"=>nil, "line5"=>nil, "city"=>"Middlefield", "country"=>nil, "country_sub_division_code"=>"CA", "postal_code"=>"94303", "note"=>nil, "lat"=>"37.4238562", "lon"=>"-122.1141681"}, class_ref: nil, sales_term_ref: {"name"=>nil, "value"=>"3", "type"=>nil}, due_date: 2014-12-03, ship_method_ref: nil, ship_date: nil, tracking_num: nil, ar_account_ref: nil, total_amount: 362.07, home_total_amount: nil, apply_tax_after_discount?: false, print_status: NeedToPrint, email_status: NotSet, balance: 362.07, deposit: 0.0, department_ref: nil, allow_ipn_payment?: false, bill_email: {"address"=>"Familiystore@intuit.com"}, allow_online_payment?: false, allow_online_credit_card_payment?: false, allow_online_ach_payment?: false>

[5] pry(main)> line_items = invoice.line_items
=> [#<Quickbooks::Model::InvoiceLineItem id: 1, line_num: 1, description: Rock Fountain, amount: 275.0, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2dc340,'0.275E3',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45d3e18f0,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
 #<Quickbooks::Model::InvoiceLineItem id: 2, line_num: 2, description: Fountain Pump, amount: 12.75, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Pump", "value"=>"11", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45c9eacc0,'0.1275E2',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45c9d9010,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
 #<Quickbooks::Model::InvoiceLineItem id: 3, line_num: 3, description: Concrete for fountain installation, amount: 47.5, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Concrete", "value"=>"3", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2bf650,'0.95E1',18(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45b1a7780,'0.5E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>,
 #<Quickbooks::Model::InvoiceLineItem id: nil, line_num: nil, description: nil, amount: 335.25, detail_type: SubTotalLineDetail, sales_line_item_detail: nil, sub_total_line_detail: {"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil}, payment_line_detail: nil, discount_line_detail: nil>]
[6] pry(main)> line_+item = line_items.first
NameError: undefined local variable or method `line_' for main:Object
from (pry):6:in `__pry__'
[7] pry(main)> line_item = line_items.first
=> #<Quickbooks::Model::InvoiceLineItem id: 1, line_num: 1, description: Rock Fountain, amount: 275.0, detail_type: SalesItemLineDetail, sales_line_item_detail: {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil}, "class_ref"=>nil, "unit_price"=>#<BigDecimal:7fa45a2dc340,'0.275E3',9(18)>, "rate_percent"=>nil, "price_level_ref"=>nil, "quantity"=>#<BigDecimal:7fa45d3e18f0,'0.1E1',9(18)>, "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil}, "service_date"=>nil}, sub_total_line_detail: nil, payment_line_detail: nil, discount_line_detail: nil>

A Regular Invoice Line Item

[8] pry(main)> line_item.attributes
=> {"id"=>1,
 "line_num"=>1,
 "description"=>"Rock Fountain",
 "amount"=>#<BigDecimal:7fa45d3f6958,'0.275E3',9(18)>,
 "detail_type"=>"SalesItemLineDetail",
 "sales_line_item_detail"=>
  {"item_ref"=>{"name"=>"Rock Fountain", "value"=>"5", "type"=>nil},
   "class_ref"=>nil,
   "unit_price"=>#<BigDecimal:7fa45a2dc340,'0.275E3',9(18)>,
   "rate_percent"=>nil,
   "price_level_ref"=>nil,
   "quantity"=>#<BigDecimal:7fa45d3e18f0,'0.1E1',9(18)>,
   "tax_code_ref"=>{"name"=>nil, "value"=>"TAX", "type"=>nil},
   "service_date"=>nil},
 "sub_total_line_detail"=>nil,
 "payment_line_detail"=>nil,
 "discount_line_detail"=>nil}

A Subtotal Line Item Detail

[13] pry(main)> line_item.attributes
=> {"id"=>nil,
 "line_num"=>nil,
 "description"=>nil,
 "amount"=>#<BigDecimal:7fa45b173430,'0.33525E3',18(18)>,
 "detail_type"=>"SubTotalLineDetail",
 "sales_line_item_detail"=>nil,
 "sub_total_line_detail"=>{"item_ref"=>nil, "class_ref"=>nil, "unit_price"=>nil, "quantity"=>nil, "tax_code_ref"=>nil},
 "payment_line_detail"=>nil,
 "discount_line_detail"=>nil}


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

Create api_customer record

  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `qb_company_info_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT '0',
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `encrypted_password` varchar(70) NOT NULL DEFAULT '',
  `salt` varchar(9) NOT NULL,
  `api_key` char(32) DEFAULT NULL,
  `newsletter` tinyint(1) NOT NULL DEFAULT '0',
  `customer_group_id` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL,
  `approved` tinyint(1) NOT NULL,
  `token` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
=end
