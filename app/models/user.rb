# == Schema Information
#
# Table name: api_customer
#
#  address_id             :integer          default(0), not null
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

  validates :approved,          inclusion: [true, false]
  validates :customer_group_id, presence: true
  validates :date_added,        presence: true # REVIEW
  validates :fax,               presence: true # ...really?
  validates :firstname,         presence: true
  validates :lastname,          presence: true
  validates :newsletter,        inclusion: [true, false]
  validates :salt,              presence: true
  validates :status,            inclusion: [true, false] # huh?
  validates :telephone,         presence: true # TODO: format
  validates :token,             presence: true # REVIEW

  after_initialize :set_defaults, if: :new_record?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  public
  
  def full_name
    "#{firstname} #{lastname}"
  end

  protected

  def set_defaults
    self.approved            = true if self.approved.nil?
    self.customer_group_id ||= 0 # REVIEW
    self.date_added        ||= DateTime.now
    self.salt              ||= "test" # TODO
    self.status              = true if self.status.nil?
    self.token             ||= "test" # TODO
  end
end
