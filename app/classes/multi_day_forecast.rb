# A SalesForecast is a multi-day sales prediction for a certain timespan.
class MultiDayForecast
  # ENDPOINT = "http://api.bigmagma.com/get/forecast/sales"
  # Endpoint = "http://#{Figaro.env.prediq_api_ip}/get/forecast/sales"

  attr_reader :days, :response

  attr_accessor :current_user

  def initialize(current_user)
    @current_user = current_user
    @days = []
  end

  # start_at, end_at ?
  def retrieve(options = {})
    fetch_data
    self.days = response.map do |day_response|
      # TODO move to adapter, ordering options.
      # It may be easier to just persist the results and then query them.
      SingleDayForecast.new(
        date:     Date.parse(day_response["Date"]),
        estimate: day_response["Forecast"].to_f,
        lower80:  day_response["Lower80"].to_f,
        lower95:  day_response["Lower95"].to_f,
        upper80:  day_response["Upper80"].to_f,
        upper95:  day_response["Upper95"].to_f,
      )
    end

    self
  end

  protected

  attr_writer :days
  attr_accessor :raw_response, :response, :current_user

  def fetch_data
    # start 2 weeks back
    startdate = startdate = DateTime.now
    # startdate = (DateTime.now - 14).strftime("%Y-%m-%d")
    conn = Faraday.new(:url => "#{Prediq::Application::ApiBaseUrl}") do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    # curl -i -H "Accept: application/json" "http://api-prediq.brownrice.com/get/forecast/sales?customerId=3&startDate=2012-01-19&intervals=14"

    response = conn.get do |request|
      request.url "#{Prediq::Application::ApiBaseUrl}#{Prediq::Application::ApiRoutes[:sales_forecast]}"
      request.params['customerId']  = current_user.id
      request.params['startDate']   = startdate
      request.params['intervals']   = 14
    end

    self.response = JSON.parse(response.body)

  end
end

=begin
  def get_information
    # start 2 weeks back
    startdate = (DateTime.now - 14).now.strftime("%Y-%m-%d")

    puts "******* Figaro.env.prediq_api_ip: #{Figaro.env.prediq_api_ip}"
    puts "******* Endpoint: #{Endpoint}"

    puts "***** current_user.id: #{current_user.id}"

    resource = RestClient::Resource.new(Endpoint)

    puts "******************** resource: #{resource}"


    self.raw_response = resource.get(
      params: {
        customerid: 2,
        startDate:  startdate,
        intervals:  7
      }
    )

    puts "*************** self.raw_response: #{self.raw_response}"

    self.response = JSON.parse(raw_response)
  end
=end


=begin
# http://stackoverflow.com/questions/4132525/getaddrinfo-nodename-nor-servname-provided-or-not-known
class CallApi < Struct.new(:num)
  def perform
    log "Entering perform"
    apinum = num || 5
    log "ApiNum = #{apinum}"
    results = attempt(2,10) do
      ActiveSupport::JSON.decode(RestClient.get(API_URL, {:params => {:apinum => apinum}}))
    end
    log "Results retrieved. (count: #{results.count})"
  end

  def log(message)
    Delayed::Worker.logger.info "[CallApi] #{Time.now} - #{message}"
  end
end
=end
