class CreateAddressInfoImports < ActiveRecord::Migration
  def change
    create_table :address_info_imports do |t|

      t.timestamps
    end
  end
end
