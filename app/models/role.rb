# == Schema Information
#
# Table name: roles
#
#  created_at    :datetime
#  id            :integer          not null, primary key
#  name          :string(255)
#  resource_id   :integer
#  resource_type :string(255)
#  updated_at    :datetime
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#

class Role < ActiveRecord::Base

  has_and_belongs_to_many :admins, :join_table => :admins_roles
  belongs_to :resource, :polymorphic => true

  scopify
  # inspired by: https://github.com/EppO/rolify/issues/156

  #require "rolify/adapters/#{Rolify.orm}/scopes.rb"
  #extend Rolify::Adapter::Scopes

  AdminsRoles     = ['superadmin','admin']
  InternalsRoles  = ['deleter','responder','salesrep','acctexec']

  # Role.internals
  scope :internals,    -> { where('name IN (?)',  InternalsRoles) }
  scope :admins,       -> { where('name IN (?)',  AdminsRoles) }

end
