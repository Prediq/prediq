require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Prediq
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    port = defined?(Rails::Server) ? (Rails::Server.new.options[:Port]) : 80
    config.action_mailer.default_url_options = {host: ENV['HOST'], port: port}

    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.autoload_paths += Dir[ config.root.join('app', 'classes', '**', '**/') ]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    ApiBaseUrl = "http://#{Figaro.env.prediq_api_ip}"

    ApiRoutes = {
      sales_forecast:         "/get/forecast/sales",
      historical_sales:       "/get/historical/sales",
      weatherstations:        "/get/weather/weatherstations",
      currenttemp:            "/get/weather/currenttemp",
      weather_data:           "/get/weather/weatherdata",
      weather_forecast:       "/get/weather/weatherforecast",
      closestweatherstation:  "/get/geo/closestweatherstation",
      location:               "/get/geo/location",
      countries:              "/get/geo/countries",
      country:                "/get/geo/country",

    }

  end
end
