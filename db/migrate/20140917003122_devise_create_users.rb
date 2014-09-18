class DeviseCreateUsers < ActiveRecord::Migration
  def up
    change_table(:api_customer) do |t|
      ## Database authenticatable
      # t.string :email,              null: false, default: ""
      t.rename :password, :encrypted_password
      t.change :encrypted_password, :string, limit: 70, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
      # t.index :api_customer, :confirmation_token,   unique: true
      # t.index :api_customer, :unlock_token,         unique: true

      t.timestamps
    end
  rescue => e
    puts "Error! Manually rolling back..."
    rollback_up
    puts "Manual rollback completed."

    raise e
  end

  def down
    # TODO: Figure out a good way to do this with MySQL.
  end

  def rollback_up
    change_table(:api_customer) do |t|
      ## Database authenticatable
      t.rename :encrypted_password, :password rescue nil

      ## Recoverable
      t.remove :reset_password_token rescue nil
      t.remove :reset_password_sent_at rescue nil

      ## Rememberable
      t.remove :remember_created_at rescue nil

      ## Trackable
      t.remove :sign_in_count rescue nil
      t.remove :current_sign_in_at rescue nil
      t.remove :last_sign_in_at rescue nil
      t.remove :current_sign_in_ip rescue nil
      t.remove :last_sign_in_ip rescue nil

      t.remove_index :email rescue nil
      t.remove_index :reset_password_token rescue nil

      t.remove :created_at rescue nil
      t.remove :updated_at rescue nil
    end
  end
end
