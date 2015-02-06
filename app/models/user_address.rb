# == Schema Information
#
# Table name: api_address
#
#  active                      :boolean
#  address_1                   :string(128)      not null
#  address_2                   :string(128)      not null
#  address_id                  :integer          not null, primary key
#  city                        :string(128)      not null
#  company                     :string(32)       not null
#  company_id                  :string(32)       not null
#  country_id                  :integer          default(0), not null
#  country_sub_division_code   :string(32)
#  customer_id                 :integer          not null
#  distance_to_weather_station :float(24)        not null
#  firstname                   :string(32)       not null
#  lastname                    :string(32)       not null
#  lat                         :float(53)        not null
#  lon                         :float(53)        not null
#  postcode                    :string(10)       not null
#  primary_address             :boolean          not null
#  qb_company_address_id       :integer          not null
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

class UserAddress < ActiveRecord::Base

  self.table_name = "api_address"

  self.primary_key = 'address_id'

  belongs_to :user, primary_key: :customer_id, foreign_key: :customer_id

end
