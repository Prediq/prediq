# == Schema Information
#
# Table name: api_customer
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

class User < ActiveRecord::Base

  self.table_name = "api_customer"

  self.primary_key = 'customer_id'

  validates :approved,          inclusion: [true, false]
  validates :customer_group_id, presence: true
  validates :date_added,        presence: true # REVIEW
  # validates :fax,               presence: true # ...really?
  validates :firstname,         presence: true
  validates :lastname,          presence: true
  validates :newsletter,        inclusion: [true, false]
  validates :salt,              presence: true
  validates :status,            inclusion: [true, false] # huh?
  validates :telephone,         presence: true # TODO: format
  validates :token,             presence: true # REVIEW
  
  has_one :quickbooks_auth
  has_one :quickbooks_auth_import

  has_many :user_addresses, primary_key: 'customer_id', foreign_key: :customer_id

  after_initialize :set_defaults, if: :new_record?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  public
  
  def full_name
    "#{firstname} #{lastname}"
  end
  
  def has_authorized_quickbooks?
    quickbooks_auth.try(:token).present?
  end

  protected

  def set_defaults
    self.approved            = 1 if self.approved.nil?
    self.customer_group_id ||= 1 # REVIEW
    self.date_added        ||= DateTime.now
    self.salt              ||= "salttest" # TODO
    self.status              = 1 if self.status.nil?
    self.token             ||= "test_token" # TODO
    self.fax                 = 0
  end
end

=begin
Create a new test user:
User.create!(qb_company_info_id: 1, store_id: 0, firstname: "Bill", lastname: "Kiskin", email: "bill.k@sbcblobal.net",telephone: "214-343-1332", fax: "214-343-1333", api_key: "bbc042e2011fb10a96d2f9b8ae_2", newsletter: 1, customer_group_id: 1, approved: 1, token: "w4t34543twdvsREQTE634Q61BDASVVZwareyqtyqrety5454", date_added: DateTime.now, password: "pleaseme", password_confirmation: "pleaseme")

[4] pry(main)> User.create!(qb_company_info_id: 1, store_id: 0, firstname: "Bill", lastname: "Kiskin", email: "bill.k@sbcblobal.net",telephone: "214-343-1332", fax: "214-343-1333", api_key: "bbc042e2011fb10a96d2f9b8ae_2", newsletter: 1, customer_group_id: 1, approved: 1, token: "w4t34543twdvsREQTE634Q61BDASVVZwareyqtyqrety5454", date_added: DateTime.now, password: "pleaseme", password_confirmation: "pleaseme")
   (0.2ms)  BEGIN
  User Exists (0.2ms)  SELECT  1 AS one FROM `api_customer`  WHERE `api_customer`.`email` = BINARY 'bill.k@sbcblobal.net' LIMIT 1
  SQL (0.2ms)  INSERT INTO `api_customer` (`api_key`, `approved`, `created_at`, `customer_group_id`, `date_added`, `email`, `encrypted_password`, `fax`, `firstname`, `lastname`, `newsletter`, `qb_company_info_id`, `salt`, `status`, `telephone`, `token`, `updated_at`) VALUES ('bbc042e2011fb10a96d2f9b8ae_2', 1, '2015-01-06 14:59:16', 1, '2015-01-06 14:59:16', 'bill.k@sbcblobal.net', '$2a$10$ISUwOL2uRZSsZ4Qqla2vQOllIIVrU4m0RAQ4a6t3U.Mqx/iyyjg92', 0, 'Bill', 'Kiskin', 1, 1, 'salttest', 1, '214-343-1332', 'w4t34543twdvsREQTE634Q61BDASVVZwareyqtyqrety5454', '2015-01-06 14:59:16')
   (1.0ms)  COMMIT
=> #<User customer_id: 9, qb_company_info_id: 1, store_id: 0, firstname: "Bill", lastname: "Kiskin", email: "bill.k@sbcblobal.net", telephone: "214-343-1332", fax: 0, encrypted_password: "$2a$10$ISUwOL2uRZSsZ4Qqla2vQOllIIVrU4m0RAQ4a6t3U.M...", salt: "salttest", api_key: "bbc042e2011fb10a96d2f9b8ae_2", newsletter: true, customer_group_id: 1, ip: "0", status: true, approved: true, token: "w4t34543twdvsREQTE634Q61BDASVVZwareyqtyqrety5454", date_added: "2015-01-06 14:59:16", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, created_at: "2015-01-06 14:59:16", updated_at: "2015-01-06 14:59:16">


=end
