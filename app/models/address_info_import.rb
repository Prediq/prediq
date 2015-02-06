# == Schema Information
#
# Table name: prediq_api_import_development.address_info_imports
#
#  address_type              :string(32)       not null
#  api_customer_id           :integer          not null
#  city                      :string(255)
#  country                   :string(255)
#  country_sub_division_code :string(255)
#  id                        :integer          not null, primary key
#  lat                       :decimal(10, 7)
#  line1                     :integer
#  line2                     :integer
#  line3                     :integer
#  line4                     :integer
#  line5                     :integer
#  lon                       :decimal(10, 7)
#  postal_code               :string(255)
#  qb_company_address_id     :integer          not null
#  qb_company_info_id        :integer          not null
#  weather_stations_id       :integer          default(0), not null
#
# Indexes
#
#  idx_api_customer_id        (api_customer_id)
#  idx_qb_company_address_id  (qb_company_address_id)
#  idx_qb_company_info_id     (qb_company_info_id)
#

class AddressInfoImport < ActiveRecord::Base

  # If used in a Rails stack:
  self.table_name = "prediq_api_import_#{Rails.env}.address_info_imports"

end
