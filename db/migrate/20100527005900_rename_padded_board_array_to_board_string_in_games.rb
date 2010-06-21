class RenamePaddedBoardArrayToBoardStringInGames < ActiveRecord::Migration
  def self.up
    rename_column('games','padded_board_array','board_string')
  end

  def self.down
    rename_column('games','board_string','padded_board_array')
  end
end
