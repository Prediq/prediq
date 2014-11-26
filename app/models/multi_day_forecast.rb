# A SalesForecast is a multi-day sales prediction for a certain timespan.
class MultiDayForecast
  # ENDPOINT = "http://api.bigmagma.com/get/forecast/sales"

  attr_reader :days, :response

  def initialize(user)
    @user = user
    @days = []
  end

  # start_at, end_at ?
  def retrieve(options = {})
    get_information
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
  attr_accessor :raw_response, :response

  def get_information
    startdate = DateTime.now.strftime("%Y-%m-%d")

    resource = RestClient::Resource.new(Figaro.env.prediq_api_ip)
    self.raw_response = resource.get(
      params: {
        customerid: 2,
        startdate:  startdate,
        intervals:  7
      }
    )

    self.response = JSON.parse(raw_response)
  end
end
