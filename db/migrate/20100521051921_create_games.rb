class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.references :player1
      t.references :player2
      t.string :padded_board_array

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
