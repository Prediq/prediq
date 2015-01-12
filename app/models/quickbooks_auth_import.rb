# == Schema Information
#
# Table name: prediq_api_development.quickbooks_auths
#
#  created_at         :datetime
#  id                 :integer          not null, primary key
#  realm_id           :string(255)
#  reconnect_token_at :datetime
#  secret             :string(255)
#  token              :string(255)
#  token_expires_at   :datetime
#  updated_at         :datetime
#  user_id            :integer
#

class QuickbooksAuthImport < ActiveRecord::Base

  self.table_name = "prediq_api_development.quickbooks_auths"


  belongs_to :user_import, foreign_key: 'user_id'
  
  def access_token
    OAuth::AccessToken.new($qb_oauth_consumer, token, secret)
  end
end
