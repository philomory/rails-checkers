require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  
  def setup
    @board = Board.new
  end
  
  
  # ===============
  # = Setup tests =
  # ===============
  
  test 'a board can be created' do
    assert_nothing_raised do
      Board.new
    end
  end
  
  test "a board allows access to its squares via rank and file" do
    assert_nothing_raised do
      result = @board.rank_and_file(4,4)
    end
  end
  
  test "a board accessed via rank and file returns a Board::Square" do
    assert_kind_of Board::Square, @board.rank_and_file(4,4)
  end
  
  test "a boardstring should be 32 characters, 1 for each square" do
    assert_raises(ArgumentError) { Board.new('___') }
  end
  
  test "a boardstring should ignore whitespace" do
    bs = <<-END_OF_BOARD
      w w w w
     w w w w
      w w w w
     _ _ _ _
      _ _ _ _
     b b b b
      b b b b
     b b b b
    END_OF_BOARD
    
    assert_nothing_raised { Board.new(bs) }  
  end
  
  test "a boardstring should only contain w, W, b, B and _" do
    assert_raises(ArgumentError) { Board.new('bbbbbbbbbbbb________ww2wwwwwwwww') }
  end
  
  test "a board string begins with the top left of the board and proceeds in reading order" do
    board = Board.new('w__W ____ ____ ____ ____ ____ ____ B__b')
    assert_equal :white_pawn, board.rank_and_file(0,0).name
    assert_equal :white_king, board.rank_and_file(0,3).name
    assert_equal :black_king, board.rank_and_file(7,0).name
    assert_equal :black_pawn, board.rank_and_file(7,3).name
  end
  
  test "a new board has a standard checkers setup" do
    rank_range(0..2) {|sq| assert sq.white_pawn? }
    rank_range(3..4) {|sq| assert sq.empty? }
    rank_range(5..7) {|sq| assert sq.black_pawn? }
  end
  
  # ==================
  # = Movement Tests =
  # ==================
  
  test "can ask about moving using index or rank and file" do
    assert_nothing_raised { @board.can_move?(0,0,:nw) }
    assert_nothing_raised { @board.can_move?(0,:ne)   }
    assert_raises(ArgumentError) { @board.can_move?(:ne) }
  end
  
  test "an empty square cannot move" do
    [:ne,:nw,:se,:sw].each do |dir|
      refute @board.can_move?(3,0,dir), "Empty spaces shouldn't move!"
    end
  end
  
  test "a pawn can move into an empty in front" do
    board = Board.new("____ __w_ ____ ____ ____ ____ _b__ ____")
    assert board.can_move?(1,2,:sw), "White pawn should move southwest"
    assert board.can_move?(1,2,:se), "White pawn should move southeast"
    assert board.can_move?(6,1,:nw), "Black pawn should move northwest"
    assert board.can_move?(6,1,:ne), "Black pawn should move northeast"
  end
  
  test "a pawn cannot move backwards" do
    board = Board.new("____ __w_ ____ ____ ____ ____ _b__ ____")
    refute board.can_move?(1,2,:nw), "White pawn should not move northwest"
    refute board.can_move?(1,2,:ne), "White pawn should not move northeast"
    refute board.can_move?(6,1,:sw), "Black pawn should not move southwest"
    refute board.can_move?(6,1,:se), "Black pawn should not move southeast"
  end
  
  test "a king moves in any direction" do
    board = Board.new("____ __W_ ____ ____ ____ ____ ____ ____")
    assert board.can_move?(1,2,:nw), "King should move northwest"
    assert board.can_move?(1,2,:ne), "King should move northeast"
    assert board.can_move?(1,2,:sw), "King should move southwest"
    assert board.can_move?(1,2,:se), "King should move southeast"
  end
  
  test "occupied squares cannot be moved into" do
    board = Board.new("____ __W_ bbbb ____ ____ ____ ____ ____")
    refute board.can_move?(1,2,:se), "Should not move into occupied square"
  end
  
  test "cannot move off the edge of the board" do
    bs = <<-END_OF_BOARD
      W W W W
     B _ _ _
      _ _ _ W
     B _ _ _
      _ _ _ W
     B _ _ _
      _ _ _ W
     B B B B
    END_OF_BOARD
    board = Board.new(bs)
    moves = {
      [0,0] => :nw, [0,0] => :ne, [0,1] => :nw, [0,1] => :ne,
      [0,2] => :nw, [0,2] => :ne, [0,3] => :nw, [0,3] => :ne,
      [1,0] => :nw, [1,0] => :sw, [3,0] => :nw, [3,0] => :sw,
      [5,0] => :nw, [5,0] => :sw, [2,3] => :ne, [2,3] => :se,
      [4,3] => :ne, [4,3] => :se, [6,3] => :ne, [6,3] => :se,
      [7,0] => :sw, [7,0] => :se, [7,1] => :sw, [7,1] => :se,
      [7,2] => :sw, [7,2] => :se, [7,3] => :sw, [7,3] => :se
    }
    moves.each_pair do |sq,dir|
      r, f = *sq
      refute board.can_move?(r,f,dir), "Piece at (#{r},#{f}) shouldn't move #{dir}!"
    end  
  end
  
  
  
  
  
  def rank_range(range,board=@board,&block)
    range.to_a.each {|r| whole_rank(r,board,&block) }
  end  
  
  def whole_rank(rank,board=@board)
    4.times do |file|
      yield board.rank_and_file(rank,file)
    end
  end

end