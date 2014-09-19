class SingleDayForecast
  include ActiveModel::Model
  attr_accessor :date, :estimate, :lower80, :lower95, :upper80, :upper95
end
