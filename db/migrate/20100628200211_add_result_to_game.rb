class AddResultToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :result, :string, :default => 'ongoing'
  end

  def self.down
    remove_column :games, :result
  end
end
