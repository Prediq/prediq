# == Schema Information
#
# Table name: prediq_api_import_development.company_info_imports
#
#  api_customer_id                           :integer
#  comm_address_city                         :string(255)
#  comm_address_country_sub_division_code    :string(255)
#  comm_address_id                           :integer
#  comm_address_lat                          :decimal(10, 7)
#  comm_address_line_1                       :string(255)
#  comm_address_line_2                       :string(255)
#  comm_address_line_3                       :string(255)
#  comm_address_line_4                       :string(255)
#  comm_address_line_5                       :string(255)
#  comm_address_lon                          :decimal(10, 7)
#  comm_address_postal_code                  :string(255)
#  company_address_city                      :string(255)
#  company_address_country_sub_division_code :string(255)
#  company_address_id                        :integer
#  company_address_lat                       :decimal(10, 7)
#  company_address_line_1                    :string(255)
#  company_address_line_2                    :string(255)
#  company_address_line_3                    :string(255)
#  company_address_line_4                    :string(255)
#  company_address_line_5                    :string(255)
#  company_address_lon                       :decimal(10, 7)
#  company_address_postal_code               :string(255)
#  company_name                              :string(255)
#  company_start_date                        :datetime
#  country                                   :string(255)
#  email                                     :string(255)
#  fiscal_year_start_month                   :string(255)
#  id                                        :integer          not null, primary key
#  legal_address_city                        :string(255)
#  legal_address_country_sub_division_code   :string(255)
#  legal_address_id                          :integer
#  legal_address_lat                         :decimal(10, 7)
#  legal_address_line_1                      :string(255)
#  legal_address_line_2                      :string(255)
#  legal_address_line_3                      :string(255)
#  legal_address_line_4                      :string(255)
#  legal_address_line_5                      :string(255)
#  legal_address_lon                         :decimal(10, 7)
#  legal_address_postal_code                 :string(255)
#  legal_name                                :string(255)
#  meta_data_create_time                     :datetime
#  primary_phone                             :string(255)
#  qb_company_info_id                        :integer
#  sync_token                                :integer
#

class CompanyInfoImport < ActiveRecord::Base

  # If used in a Rails stack:
  self.table_name = "prediq_api_import_#{Rails.env}.company_info_imports"

  # NOTE: Here so we can connect to its DB if we are running the app in development, staging, or production modes as a regular rails app
  # To use these for the standalone Ruby job we pass in the rails_env params as 'import_development', 'import_staging', 'production_import'
  # where we have already established a DB connection
  # establish_connection "import_#{Rails.env}" if ('development,staging,production').include?(Rails.env)

  # establish_connection(Rails.configuration.database_configuration["import_#{Rails.env}"]) if ('development,staging,production').include?(Rails.env)

end
