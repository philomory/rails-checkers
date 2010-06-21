Game.blueprint do
  player1 { User.make }
  player2 { User.make }
  board_string { Board::DEFAULT_BOARD_STRING }
end
