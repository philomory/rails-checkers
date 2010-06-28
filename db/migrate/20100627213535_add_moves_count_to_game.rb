class AddMovesCountToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :moves_count, :integer, :default => 0
  end

  def self.down
    remove_column :games, :moves_count
  end
end
