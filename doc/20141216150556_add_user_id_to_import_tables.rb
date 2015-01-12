class AddUserIdToImportTables < ActiveRecord::Migration

  # def connection
  #   ActiveRecord::Base.establish_connection("import_#{Rails.env}").connection
  # end

  def change
    # add_column "prediq_api_import_#{Rails.env}.company_info_imports",  :api_customer_id, :integer
    # add_column "prediq_api_import_#{Rails.env}.sales_receipt_imports",  :api_customer_id, :integer
    # add_column "prediq_api_import_#{Rails.env}.line_item_imports",      :api_customer_id, :integer
  end

end

=begin

local machine:
# NOTE: uses the database.yml's 'import_development' config to create the DB
$ RAILS_ENV=import_development bundle exec rake db:create
$ RAILS_ENV=development bundle exec rake db:migrate

staging server (after a deploy to get the new database.yml code up there):
$ RAILS_ENV=import_staging bundle exec rake db:create
$ RAILS_ENV=staging bundle exec rake db:migrate

=end
