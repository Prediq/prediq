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

  def invoices
    service = Quickbooks::Service::Customer.new
    util = Quickbooks::Util::QueryBuilder.new

    # the method signature is: clause(field, operator, value)
    clause1 = util.clause("DisplayName", "LIKE", "%O'Halloran")
    clause2 = util.clause("CompanyName", "=", "Smith")

    service.query("SELECT * FROM Invoice")
  end
end