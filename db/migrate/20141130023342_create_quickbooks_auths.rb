class CreateQuickbooksAuths < ActiveRecord::Migration
  def change
    create_table :quickbooks_auths do |t|
      t.integer :user_id
      t.string :token
      t.string :secret
      t.string :realm_id
      t.datetime :token_expires_at
      t.datetime :reconnect_token_at

      t.timestamps
    end
  end
end
