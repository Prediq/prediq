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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
