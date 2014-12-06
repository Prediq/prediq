class QuickbooksCommunicator
  attr_accessor :quickbooks_auth
  
  def initialize(quickbooks_auth)
    @quickbooks_auth = quickbooks_auth
  end
  
  def customers_list
    service = Quickbooks::Service::Customer.new
    service.company_id = quickbooks_auth.realm_id
    service.access_token = quickbooks_auth.access_token
    # Equivalent to Quickbooks::Service::Customer.new(:company_id => "123", :access_token => access_token)

    customers = service.query() # Called without args you get the first page of results
    # yields

    # customers.entries = [ .. array of Quickbooks::Model::Customer objects .. ]
    # customers.start_position = 1 # the current position in the paginated set
    # customers.max_results = 20 # the maximum number of results in this query set
  end

  def sales_receipts
    service = Quickbooks::Service::SalesReceipt.new
    service.company_id = quickbooks_auth.realm_id
    service.access_token = quickbooks_auth.access_token

    service.query
  end

  def company_info
    service = Quickbooks::Service::CompanyInfo.new
    service.company_id = quickbooks_auth.realm_id
    service.access_token = quickbooks_auth.access_token

    service.query
  end
end