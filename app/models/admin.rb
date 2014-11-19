# == Schema Information
#
# Table name: admins
#
#  authentication_token   :string(255)
#  created_at             :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  id                     :integer          not null, primary key
#  last_name              :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0), not null
#  updated_at             :datetime
#
# Indexes
#
#  index_admins_on_authentication_token  (authentication_token) UNIQUE
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_last_name             (last_name)
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#

class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable

  # NOTE: We use 'admin_id' to mark the record with who marked it as deleted, if that was done,
  # and we use 'reply_tweet_admin_id' to mark the 'replied' conversation with the admin who replied to it, if it was replied to
  has_many  :conversations
  has_many  :curated_conversations
  has_many  :replied_conversations, foreign_key: 'reply_tweet_admin_id', class_name: 'Conversation'

  paginates_per 10 # kaminari pagination

  # attr_accessor :role_ids

  validates_presence_of :role_ids, :message => 'You must select a Role.'

  def last_first
    if first_name.blank?
      'No user name entered'
    else
      [ last_name, first_name ].join(', ')
    end
  end

  # can also do: adminusers = Role.find_by_name('admin').admins
  # Admin.with_role :admin
  rolify

  validates_presence_of :first_name, :last_name

  before_save :ensure_authentication_token

  def ensure_authentication_token
    if self.authentication_token.blank?
      o =  [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
      # add some hyphens and underscores in random positions
      3.times do
        o.insert(rand(o.length),"-")
        o.insert(rand(o.length),"_")
      end

      self.authentication_token = (0..20).map{ o[rand(o.length)]  }.join
    end
  end

  def self.new_password
    o =  [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
    (0..10).map{ o[rand(o.length)]  }.join
  end

  def print_roles
    self.roles(:select => :name).collect(&:name).join(",")
  end

end

