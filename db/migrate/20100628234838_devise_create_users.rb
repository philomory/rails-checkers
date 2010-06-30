class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    drop_table :users
    
    create_table(:users) do |t|
      t.string :username, :null => false
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.timestamps
    end
    
    add_index :users, :email,                :unique => true
    add_index :users, :username,             :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
    
    create_table "users" do |t|
      t.string   "login"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
end
