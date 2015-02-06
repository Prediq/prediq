# == Schema Information
#
# Table name: prediq_api_development.api_customer
#
#  api_key                :string(32)
#  approved               :boolean          not null
#  created_at             :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  customer_group_id      :integer          not null
#  customer_id            :integer          not null, primary key
#  date_added             :datetime         not null
#  email                  :string(96)       not null
#  encrypted_password     :string(70)       default(""), not null
#  fax                    :string(32)       not null
#  firstname              :string(32)       not null
#  ip                     :string(40)       default("0"), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  lastname               :string(32)       not null
#  newsletter             :boolean          default(FALSE), not null
#  qb_company_info_id     :integer          not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  salt                   :string(9)        not null
#  sign_in_count          :integer          default(0), not null
#  status                 :boolean          not null
#  store_id               :integer          default(0), not null
#  telephone              :string(32)       not null
#  token                  :string(255)      not null
#  updated_at             :datetime
#
# Indexes
#
#  api_key                                     (api_key) UNIQUE
#  index_api_customer_on_email                 (email) UNIQUE
#  index_api_customer_on_reset_password_token  (reset_password_token) UNIQUE
#

class UserImport < ActiveRecord::Base

  # NOTE: Here so we can connect to its DB if we are running the app in import_development, import_staging, or import_production modes as a regular rails app
  # To use these for the standalone Ruby job we pass in the rails_env params as 'import_development', 'import_staging', 'production_import'
  # where we have already established a DB connection
  # We really want to connect to the "regular" non-import DB to access this relation
  # "import_development".tap{|s| s.slice!("import_")}
  # establish_connection "#{Rails.env.slice!('import_')}" if ('import_development,import_staging,import_production').include?(Rails.env)
  # establish_connection "prediq_api_#{Rails.env.tap{|s| s.slice!("import_")}}" if ('import_development,import_staging,import_production').include?(Rails.env)

  # self.table_name = "prediq_api_development.api_customer"

  # If used in a Rails stack:
  self.table_name = "prediq_api_#{Rails.env}.api_customer"

  self.primary_key = 'customer_id'
  
  has_one :quickbooks_auth_import, foreign_key: 'user_id'

  has_many :user_addresses, primary_key: 'customer_id', foreign_key: :customer_id

  def full_name
    "#{firstname} #{lastname}"
  end
  
  def has_authorized_quickbooks?
    quickbooks_auth.try(:token).present?
  end

end

=begin
user = UserImport.find 2
user.quickbooks_auth_import
=end
