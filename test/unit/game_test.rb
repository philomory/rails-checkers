require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "should create a game" do
    assert_difference 'Game.count' do
      game = Game.make
      assert !game.new_record?, "#{game.errors.full_messages.to_sentence}"
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
    skip
    assert_kind_of Board, Game.make.board
  end
  
  
end
