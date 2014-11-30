# == Schema Information
#
# Table name: quickbooks_auths
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

require 'test_helper'

class QuickbooksAuthTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
