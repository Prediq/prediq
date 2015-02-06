class ImportDailyData

  # 1. Get sales_receipts => needs to get the data where the transaction_date > the MAX(transaction_date)
  # that we already have, then shove it into the DW

end

=begin
To get quickbooks data at the console:

1. In a browser log in as user 2 "tc2@bigmagma.com" authenticate QB to create the user and create the QuickbooksAuth
record for that user so we can next hit QB for the data
  a. dashboard page, click Connect to QB as you can use wes@prediq.com pr3d1q

2. In console
  a. user = User.find 2
  b. company_info = QuickbooksCommunicator.new(user.quickbooks_auth).company_info
  c. sales_receipts = QuickbooksCommunicator.new(user.quickbooks_auth).sales_receipts
=end
