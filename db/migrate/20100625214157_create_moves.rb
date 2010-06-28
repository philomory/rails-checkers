class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.references :game
      t.integer :ply
      t.string :move_string

      t.timestamps
    end
    
    add_index :moves, [:game_id, :ply], :name => 'game_ply_on_move', :unique => :true
  end

  def self.down
    drop_table :moves
  end
end
