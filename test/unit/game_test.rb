require 'test_helper'

class GameTest < ActiveSupport::TestCase

  # ===============
  # = Game Basics =
  # ===============

  test "should create a game" do
    assert_difference 'Game.count' do
      game = Game.make
      assert !game.new_record?, "#{game.errors.full_messages.to_sentence}"
    end
  end
  
  test "a game without a board string shouldn't be allowed" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Game.make(:board_string => nil)
    end
  end
  
  test "a game without player1 shouldn't be allowed" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Game.make(:player1 => nil)
    end
  end
  
  test "a game without player2 shouldn't be allowed" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Game.make(:player2 => nil)
    end
  end
  
  test "a game shouldn't allow player1 and player2 to be the same" do
    assert_raises(ActiveRecord::RecordInvalid) do
      user = User.make
      Game.make(:player1 => user, :player2 => user)
    end
  end
  
  test "a game will give you its board" do
    assert_kind_of Board, Game.make.board
  end
  
  test "a game should provide players given colors" do
    game = Game.make
    assert_equal game.player1, game.player_for_color(:white)
    assert_equal game.player2, game.player_for_color(:black)
  end
  
  test "a game should provide colors given players" do
    game = Game.make
    assert_equal :white, game.color_for_player(game.player1)
    assert_equal :black, game.color_for_player(game.player2)
  end
  
  # ========================
  # = Game-move processing =
  # ========================
  
  test "a new game should have 0 moves" do
    assert_equal 0, Game.make.moves.size
  end
  
  test "a new game should start with white to move" do
    game = Game.make
    assert_equal :white, game.color_to_move
    assert_equal game.player1, game.player_to_move
  end
  
  test "should translate from move_strings to argument arrays" do
    game = Game.make
    assert_equal [:white, 0, 0, {:move => :se}], game.process_move_string('00mse')
    assert_equal [:white, 0, 0, {:jump => [:se,:sw,:ne,:nw]}], game.process_move_string('00jseswnenw')
  end
  
  test "a move made should change the board" do
    game = Game.make
    control = game.board
    control.do_take_turn(:white,2,0,:move => :se)
    game.move(game.player1,'20mse')
    assert_equal control, game.board
  end
  
  test "a move made should be recorded" do
    game = Game.make
    assert_difference('game.moves.size') do
      game.move(game.player1,'20mse')
    end
  end
  
  test "an invalid move should not change the board" do
    game = Game.make
    control = game.board
    game.move(game.player1,'30mse') rescue nil # There's no piece there
    assert_equal control, game.board
  end
  
  test "an invalid move shold not be recorded" do
    game = Game.make
    assert_no_difference('game.moves.size') do
      game.move(game.player1,'30mse') rescue nil
    end
  end
  
  test "after each move, play should change sides" do
    game = Game.make
    assert_equal :white, game.color_to_move
    game.move(game.player1,'20mse')
    assert_equal :black, game.color_to_move
    game.move(game.player2,'53mne')
    assert_equal :white, game.color_to_move
    game.move(game.player1,'21mse')
    assert_equal :black, game.color_to_move
  end
  
  test "after eliminating the last opposing piece, you should win the game" do
    bs = <<-END_OF_BOARD
      w _ _ _
     _ b _ _
      _ _ _ _ ____________________
    END_OF_BOARD
    game = Game.make(:board_string => bs)
    game.move(game.player1,'00jse')
    assert_equal :white_elim, game.result
  end
  
  test "if the player to move has no moves available, then they lose" do
    bs = <<-END_OF_BOARD
     w _ _ w
    b b _ _
     _ b b _ ____________________
    END_OF_BOARD
    game = Game.make(:board_string => bs)
    game.move(game.player1,'03msw')
    game.move(game.player2,'22jne')
    assert_equal :black_lock, game.result
  end
  
  test "if a player conceeds, the other player wins the game" do
    game = Game.make
    game.conceed(:white)
    assert_equal :black_give, game.result
  end
  
  test "You can't move if the game is not ongoing" do
    game = Game.make(:result => :white_give)
    control = game.board
    assert_no_difference('game.moves.size') do
      game.move(game.player1,'20msw')
    end
    assert_equal control, game.board
  end
  
  test "You can only conceed if the game is currently in progress" do
    game = Game.make(:result => :abandoned)
    game.conceed(:black)
    assert_equal :abandoned, game.result
  end
  
end
