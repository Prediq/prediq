# == Schema Information
#
# Table name: api_address
#
#  address_1                   :string(128)      not null
#  address_2                   :string(128)      not null
#  address_id                  :integer          not null, primary key
#  city                        :string(128)      not null
#  company                     :string(32)       not null
#  company_id                  :string(32)       not null
#  country_id                  :integer          default(0), not null
#  customer_id                 :integer          not null
#  distance_to_weather_station :float(24)        not null
#  firstname                   :string(32)       not null
#  lastname                    :string(32)       not null
#  lat                         :float(53)        not null
#  lon                         :float(53)        not null
#  postcode                    :string(10)       not null
#  primary_address             :boolean          not null
#  tax_id                      :string(32)       not null
#  weather_station_code        :string(16)       not null
#  weather_station_id          :integer          not null
#  zone_id                     :integer          default(0), not null
#
# Indexes
#
#  customer_id      (customer_id)
#  primary_address  (primary_address)
#

require 'test_helper'

class UserAddressTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
