class AdminsRole < ActiveRecord::Base

  belongs_to :admin
  belongs_to :roles

end
