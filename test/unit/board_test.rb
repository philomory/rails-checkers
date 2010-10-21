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
    board = edge_test_board
    moves = {
      [0,0] => :nw, [0,0] => :ne, [0,1] => :nw, [0,1] => :ne,
      [0,2] => :nw, [0,2] => :ne, [0,3] => :nw, [0,3] => :ne, [0,3] => :se,
      [1,0] => :nw, [1,0] => :sw, [3,0] => :nw, [3,0] => :sw,
      [5,0] => :nw, [5,0] => :sw, [2,3] => :ne, [2,3] => :se,
      [4,3] => :ne, [4,3] => :se, [6,3] => :ne, [6,3] => :se,
      [7,0] => :nw, [7,0] => :sw, [7,0] => :se, [7,1] => :sw, [7,1] => :se,
      [7,2] => :sw, [7,2] => :se, [7,3] => :sw, [7,3] => :se
    }
    moves.each_pair do |sq,dir|
      r, f = *sq
      refute board.can_move?(r,f,dir), "Piece at (#{r},#{f}) shouldn't move #{dir}!"
    end  
  end
  
  test "moving takes you to the destination square" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ w _ _
      _ _ _ _
     _ _ _ _
      _ _ _ _
     _ _ _ _
      _ _ _ _
     _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    board.do_move(1,1,:se)
    assert board.rank_and_file(1,1).empty?
    assert board.rank_and_file(2,1).white_pawn?
  end
  
  # =================
  # = Jumping Tests =
  # =================
  
  test "can ask about jumping using index or rank and file" do
    assert_nothing_raised { @board.can_jump?(0,0,:nw) }
    assert_nothing_raised { @board.can_jump?(0,:ne)   }
    assert_raises(ArgumentError) { @board.can_jump?(:ne) }
  end
  
  test "an empty square cannot jump" do
    [:ne,:nw,:se,:sw].each do |dir|
      refute @board.can_jump?(3,0,dir), "Empty spaces shouldn't jump!"
    end
  end
  
  test "a pawn can jump forwards" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ _ w _
      _ b b _
     _ _ _ _
      _ _ _ _
     _ w w _
      _ b _ _
     _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.can_jump?(1,2,:sw), "White pawn should jump southwest"
    assert board.can_jump?(1,2,:se), "White pawn should jump southeast"
    assert board.can_jump?(6,1,:nw), "Black pawn should jump northwest"
    assert board.can_jump?(6,1,:ne), "Black pawn should jump northeast"
  end
    
  test "a pawn cannot jump backwards" do
    board = Board.new("____ bbbb __w_ ____ ____ _b__ wwww ____")
    refute board.can_jump?(2,2,:nw), "White pawn should not jump northwest"
    refute board.can_jump?(2,2,:ne), "White pawn should not jump northeast"
    refute board.can_jump?(5,1,:sw), "Black pawn should not jump southwest"
    refute board.can_jump?(5,1,:se), "Black pawn should not jump southeast"
  end
    
  test "a king jumps in any direction" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ b b _
      _ W _ _
     _ b b _
      _ _ _ _
     _ _ _ _
      _ _ _ _
     _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    
    assert board.can_jump?(2,1,:nw), "King should jump northwest"
    assert board.can_jump?(2,1,:ne), "King should jump northeast"
    assert board.can_jump?(2,1,:sw), "King should jump southwest"
    assert board.can_jump?(2,1,:se), "King should jump southeast"
  end
  
  test "a jump must land on an empty square" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ _ w _
      _ b b _
     _ b _ w
      _ _ _ _
     _ _ _ _
      _ _ _ _
     _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
  
    refute board.can_jump?(1,2,:se), "a jump must land in an empty square"
    refute board.can_jump?(1,2,:sw), "a jump must land in an empty square"
  end
  
  test "a piece cannot jump over an empty square" do
    board = Board.new("____ ____ __w_ ____ ____ ____ ____ ____")
    refute board.can_jump?(2,2,:sw), "should not jump over an empty square"
  end
  
  test "a piece can only jump over another piece of a different color" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ _ w _
      _ b w _
     _ _ _ _
      _ _ _ _
     _ b w _
      _ b _ _
     _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.can_jump?(1,2,:sw), "White should jump over black"
    refute board.can_jump?(1,2,:se), "White should not jump over white"
    refute board.can_jump?(6,1,:nw), "Black should not jump northwest"
    assert board.can_jump?(6,1,:ne), "Black should jump over white"
  end
  
  test "a piece cannot jump off the edge of the board" do
    board = edge_test_board
    outer_moves = {
      [0,0] => :nw, [0,0] => :ne, [0,1] => :nw, [0,1] => :ne,
      [0,2] => :nw, [0,2] => :ne, [0,3] => :nw, [0,3] => :ne, [0,3] => :se,
      [1,0] => :nw, [1,0] => :sw, [3,0] => :nw, [3,0] => :sw,
      [5,0] => :nw, [5,0] => :sw, [2,3] => :ne, [2,3] => :se,
      [4,3] => :ne, [4,3] => :se, [6,3] => :ne, [6,3] => :se,
      [7,0] => :nw, [7,0] => :sw, [7,0] => :se, [7,1] => :sw, [7,1] => :se,
      [7,2] => :sw, [7,2] => :se, [7,3] => :sw, [7,3] => :se
    }
    
    inner_moves = {
      [1,1] => :nw, [1,1] => :ne, [1,2] => :nw, [1,2] => :ne,
      [1,3] => :nw, [1,3] => :ne, [1,3] => :se,
      [2,0] => :nw, [2,0] => :sw, [4,0] => :nw, [4,0] => :sw,
      [3,3] => :ne, [3,3] => :se, [5,3] => :ne, [5,3] => :se, 
      [6,0] => :nw, [6,0] => :sw, [6,0] => :se, [6,1] => :sw, 
      [6,1] => :se, [6,2] => :sw, [6,2] => :se
    }
    outer_moves.each_pair do |sq,dir|
      r, f = *sq
      refute board.can_jump?(r,f,dir), "Piece at (#{r},#{f}) shouldn't jump #{dir}!"
    end
    inner_moves.each_pair do |sq,dir|
      r, f = *sq
      refute board.can_jump?(r,f,dir), "Piece at (#{r},#{f}) shouldn't jump #{dir}!"
    end  
  end
  
  test "jumping takes you to the destination square" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ w _ _
      _ b _ _
     _ _ _ _ ________________
    END_OF_BOARD
    board = Board.new(bs)
    board.do_jump(1,1,:se)
    assert board.rank_and_file(1,1).empty?, "white pawn should no longer be in this square!"
    assert board.rank_and_file(3,2).white_pawn?, "white pawn should be in this square now!"
  end
  
  test "jumping removes the piece you jumped over" do
    bs = <<-END_OF_BOARD
      _ _ _ _
     _ w _ _
      _ b _ _
     _ _ _ _ ________________
    END_OF_BOARD
    board = Board.new(bs)
    board.do_jump(1,1,:se)
    assert board.rank_and_file(2,1).empty?, "black pawn should have been removed!"
  end
  
  # =======================
  # = Multi-jumping Tests =
  # =======================
  
  test "can ask about jumping in sequence using index or rank and file" do
    assert_nothing_raised("should multi-jump with rank and file") { @board.can_multi_jump?(0,0,:sw,:sw,:sw)    }
    assert_nothing_raised("should multi-jump with index") { @board.can_multi_jump?(0,:se,:se,:se)      }
    assert_raises(ArgumentError, "should raise argument error without any form of index") { @board.can_multi_jump?(:se,:se,:se) }
  end
  
  test "can jump over many squares" do
    bs = <<-END_OF_BOARD
        _ W _ _
       _ b b _
        _ _ _ _
       _ b b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    assert board.can_multi_jump?(0,1,:sw,:se,:ne,:nw), "should jump over many squares"
  end
  
  test "cannot multi-jump over zero squares" do
    board = Board.new('__w_____________________________')
    refute board.can_multi_jump?(0,2)
  end
  
  test "cannot re-jump over the same square twice" do
    bs = <<-END_OF_BOARD
        _ W _ _
       _ b b _
        _ _ _ _
       _ b b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.can_multi_jump?(0,1,:sw,:se,:ne,:nw,:sw), "Should not jump over the same square twice (the victim should have been removed by now)"    
  end
  
  test "a multi-jump should move the jumper to its final destination" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    board.do_multi_jump(0,3,:sw,:sw)
    assert board.rank_and_file(0,3).empty?, "initial position should be empty"
    assert board.rank_and_file(2,2).empty?, "intermediate position should be empty"
    assert board.rank_and_file(4,1).white_pawn?, "white pawn should have arrived at final square"
  end
  
  test "a multi-jump should remove all the victims" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    board.do_multi_jump(0,3,:sw,:sw)
    assert board.rank_and_file(1,3).empty?, "first victim should be removed"
    assert board.rank_and_file(3,2).empty?, "second victim should be removed"
  end
  
  test "should not in fact jump zero squares" do
    board = Board.new('__w_____________________________')
    assert_raises(Board::MoveError) { board.do_multi_jump(0,2) }
  end
  
  # ===================
  # = Full Turn Tests =
  # ===================
  
  test "can ask about legal turns using index or rank and file" do
    assert_nothing_raised { @board.can_take_turn?(:white,0,0,:move => :sw)    }
    assert_nothing_raised { @board.can_take_turn?(:white,0,:move => :sw)      }
    assert_raises(ArgumentError) { @board.can_take_turn?(:white,:move => :sw) }
  end
  
  test "must provide color when asking about turns" do
    assert_raises(ArgumentError) { @board.can_take_turn?(0,0,:move => :sw) }
  end
  
  test "must provide either move or jump arg, but not both" do
    assert_nothing_raised { @board.can_take_turn?(:white,0,0,:move => :sw) }
    assert_nothing_raised { @board.can_take_turn?(:white,0,0,:jump => :sw) }
    assert_raises(ArgumentError) { @board.can_take_turn?(:white,0,0,:foo => :bar) }
    assert_raises(ArgumentError) { @board.can_take_turn?(:white,0,0,:move => :sw, :jump => :nw) }
  end
  
  test "color of the player must match the color of the piece being moved" do
    bs = <<-END_OF_BOARD
        _ _ _ _
       _ w _ _
        _ _ _ _
       _ _ b _ ________________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.can_take_turn?(:white,3,2,:move => :nw), "White should not move black piece"
    refute board.can_take_turn?(:black,1,1,:move => :se), "Black should not move white piece"
  end
  
  test "a legal move comes back true" do
    board = Board.new('w_______________________________')
    assert board.can_take_turn?(:white,0,0,:move => :se), "should be able to move this way"
  end
  
  test "an illegal move comes back false" do
    board = Board.new('w_______________________________')
    refute board.can_take_turn?(:white,0,0,:move => :ne), "should not be able to move that way"
  end
  
  test "a legal jump comes back true" do
    bs = <<-END_OF_BOARD
        _ _ w _
       _ _ b _
        _ _ _ _ ____________________
    END_OF_BOARD
    board = Board.new(bs)
    assert board.can_take_turn?(:white,0,2,:jump => :sw)
  end
  
  test "an illegal jump comes back false" do
    board = Board.new('w_______________________________')
    refute board.can_take_turn?(:white,0,0,:jump => :se)
  end
  
  test "a legal series of jumps comes back true" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    assert board.can_take_turn?(:white,0,3,:jump => [:sw,:sw])
  end
  
  test "an illegal series of jumps comes back false" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.can_take_turn?(:white,0,3,:jump => [:sw,:se]), "this move should be illegal"
  end
  
  test "when jumping, you cannot stop if there are still jumps available to continue with" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.can_take_turn?(:white,0,3,:jump => :sw), "should require the jump to be continued"
  end
  
  test "cannot make a normal move if a jump is available" do
    bs = <<-END_OF_BOARD
        _ _ w _
       _ _ _ b
        _ _ _ _ ____________________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.can_take_turn?(:white,0,2,:move => :sw), "should not be able to move if jump is available"
  end
  
  test "taking at turn should move your piece" do
    board = Board.new('w_______________________________')
    board.do_take_turn(:white,0,0,:move => :sw)
    assert board.rank_and_file(0,0).empty?, "piece should not be here any more"
    assert board.rank_and_file(1,0).white_pawn?, "piece should be here now"
  end
  
  test "taking a turn should jump your piece" do
    bs = <<-END_OF_BOARD
        _ _ _ w
       _ _ _ b
        _ _ _ _
       _ _ b _
        _ _ _ _ ____________
    END_OF_BOARD
    board = Board.new(bs)
    board.do_take_turn(:white,0,3,:jump => [:sw,:sw])
    assert board.rank_and_file(0,3).empty?
    assert board.rank_and_file(1,3).empty?
    assert board.rank_and_file(2,2).empty?
    assert board.rank_and_file(3,2).empty?
    assert board.rank_and_file(4,1).white_pawn?
  end
  
  test "moving to the end of the board should make a pawn a king" do
    board = Board.new('______b_________________________')
    board.do_take_turn(:black,1,2,:move => :ne)
    assert board.rank_and_file(0,2).black_king?, "pawn should have been kinged"
  end
  
  test "jumping to the end of the board should make a pawn a king" do
    bs = <<-END_OF_BOARD
         _ _ _ _
        _ _ _ _
         _ _ _ _
        _ _ _ _
         _ _ _ _
        _ _ w _
         _ _ b _
        _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    board.do_take_turn(:white,5,2,:jump => :se)
    assert board.rank_and_file(7,3).white_king?, "pawn should have been kinged"
  end

  # ===========================
  # = Move availability tests =
  # ===========================
  
  test "the availablity of a white pawn move is noticed" do
    bs = <<-END_OF_BOARD
       B w B B
      B B _ B
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.move_available?(:white), "white has a move available"
  end
  
  test "the availability of a white king move is noticed" do
    bs = <<-END_OF_BOARD
        _ _ _ _
       _ _ _ _
        _ _ _ _
       _ _ _ _
        _ _ _ _
       _ _ _ _
        b _ b b
       b b W b
    END_OF_BOARD
    board = Board.new(bs)
    assert board.move_available?(:white), "white has a move available"
  end
  
  test "the unavailablity of any white moves is noticed" do
    bs = <<-END_OF_BOARD
      ____________________
      b b b b
       b b b b
      b b W b
    END_OF_BOARD
    board = Board.new(bs)
    refute board.move_available?(:white), "white has no moves available"
  end
  
  test "the availablity of a black pawn move is noticed" do
    bs = <<-END_OF_BOARD
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
       W _ W W
      W W b W
    END_OF_BOARD
    board = Board.new(bs)
    assert board.move_available?(:black), "white has a move available"
  end
  
  test "the availability of a black king move is noticed" do
    bs = <<-END_OF_BOARD
       w B w w
      w w _ w
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
       _ _ _ _
      _ _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.move_available?(:black), "white has a move available"
  end
  
  test "the unavailablity of any black moves is noticed" do
    bs = <<-END_OF_BOARD
       w B w w
      w w w w
       w w w w
      ____________________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.move_available?(:black), "white has no moves available"
  end
  
  test "can find all available white moves" do
    bs = <<-END_OF_BOARD
        w w w w
       w w w w
        w _ w w
       _ W _ _
        _ _ _ _ ___________b
    END_OF_BOARD
    board = Board.new(bs)
    expected = {[2,0] => [:sw], [2,2] => [:se,:sw], [2,3] => [:sw], [3,1] => [:ne,:se,:sw], [1,2] => [:sw], [1,1] => [:se] }
    actual = board.available_moves(:white)
    assert_equal expected, actual
  end
  
  # ===========================
  # = Jump availability tests =
  # ===========================
  
  test "the availability of a white pawn jump is noticed" do
    bs = <<-END_OF_BOARD
       _ _ _ w
      _ _ _ b
       _ _ _ _ ____________________
    END_OF_BOARD
    board = Board.new(bs)
    assert board.jump_available?(:white), "white has a jump available"
  end
  
  test "the availability of a white king jump is noticed" do
    bs = <<-END_OF_BOARD
      ____________________
      _ _ _ _
       b _ _ _
      W _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.jump_available?(:white), "white has a jump available"
  end
  
  test "the unavailability of any white jumps is noticed" do
    bs = <<-END_OF_BOARD
      ____________________
      b b b b
       b b b b
      b b W b
    END_OF_BOARD
    board = Board.new(bs)
    refute board.jump_available?(:white), "white has no jumps available"
  end
  
  test "the availability of a black pawn move is noticed" do
    bs = <<-END_OF_BOARD
      ____________________
      _ _ _ _
       w _ _ _
      b _ _ _
    END_OF_BOARD
    board = Board.new(bs)
    assert board.jump_available?(:black), "black has a jump available"
  end
  
  test "the availability of a black king jump is noticed" do
    bs = <<-END_OF_BOARD
       _ _ _ B
      _ _ _ w
       _ _ _ _ ____________________
    END_OF_BOARD
    board = Board.new(bs)
    assert board.jump_available?(:black), "black has a jump available"
  end
  
  test "the unavailability of any black jump is noticed" do
    bs = <<-END_OF_BOARD
       w B w w
      w w w w
       w w w w
      ____________________
    END_OF_BOARD
    board = Board.new(bs)
    refute board.jump_available?(:black), "black has no jumps available"
  end
  
  test "can find all available black jumps" do
    bs = <<-END_OF_BOARD
       _ _ _ B
      b w W _
       w B b _
      w _ w _
       b _ _ _
      w _ w _
       w b _ b
      b b b b
    END_OF_BOARD
    board = Board.new(bs)
    expected = {
      [2,1] => [:ne,:nw,:se],
      [2,2] => [:nw],
      [6,1] => [:ne],
      [7,0] => [:ne]
    }
    actual = board.available_jumps(:black)
    assert_equal expected, actual
  end
  
  
  # =====================
  # = Available Actions =
  # =====================
  
  test "A board with available jumps returns only jumps" do
    bs = <<-END_OF_BOARD
       _ _ _ B
      b w W _
       w B b _
      w _ w _
       b _ _ _
      w _ w _
       w b _ b
      b b b b
    END_OF_BOARD
    board = Board.new(bs)
    expected = {
      :type => :jump,
      [2,1] => [:ne,:nw,:se],
      [2,2] => [:nw],
      [6,1] => [:ne],
      [7,0] => [:ne]
    }
    actual = board.available_actions(:black)
    assert_equal expected, actual
  end
  
  test "A board with available moves and no jumps reports the moves" do
    board = Board.new('wwww___________________________b')
    expected = {
      :type => :move,
      [0,0] => [:se,:sw],
      [0,1] => [:se,:sw],
      [0,2] => [:se,:sw],
      [0,3] => [:sw]
    }
    actual = board.available_actions(:white)
    assert_equal expected, actual
  end
  
  test "A board with no available moves or jumps reports nothing (i.e. nil)" do
    bs = <<-END_OF_BOARD
       w B w w
      w w w w
       w w w w
      ____________________
    END_OF_BOARD
    board = Board.new(bs)
    assert_nil board.available_actions(:black)
  end
  
  # ======================
  # = Win Condition test =
  # ======================
  
  test "a board with both white and black pieces is not a win for either side" do
    assert_nil Board.new.winner, "neither side should win when pieces of both colors are in play"
  end
  
  test "a board with no white pieces is a win for black" do
    board = Board.new('_______________________________b')
    assert_equal :black, board.winner, "black should win with no white pieces"
  end
  
  test "a board with no black pieces is a win for white" do
    board = Board.new('w_______________________________')
    assert_equal :white, board.winner, "white should win with no black pieces"
  end
  
  # ======================
  # = Miscelaneous tests =
  # ======================
  
  test "a board can give its position as a string" do
    bs = 'w__W________________________B__b'
    board = Board.new(bs)
    assert_equal bs, board.position_string
  end
  
  test "boards with equal positions are equal" do
    bs = 'w__W________________________B__b'
    board1 = Board.new(bs)
    board2 = Board.new(bs)
    assert (board1 == board2), "boards in equal positions should be consider equal"
  end
  
  test "a duplicate board begins in the same position" do
    board1 = Board.new('w__W________________________B__b')
    board2 = board1.dup
    assert_equal board1, board2
  end
  
  test "a duplicate board changes independently of the original" do
    bs = 'w__W________________________B__b'
    board1 = Board.new(bs)
    board2 = board1.dup
    
    board2.do_move(0,0,:se)
    refute_equal board1, board2, "board2 should no longer look like board 1"
    assert_equal bs, board1.position_string, "board1 should not have changed at all"
  end

  # ====================
  # = Helper functions =
  # ====================
  
  def rank_range(range,board=@board,&block)
    range.to_a.each {|r| whole_rank(r,board,&block) }
  end  
  
  def whole_rank(rank,board=@board)
    4.times do |file|
      yield board.rank_and_file(rank,file)
    end
  end
  
  def edge_test_board
    bs = <<-END_OF_BOARD
      W W W W
     W B B B
      B _ _ W
     W _ _ B
      B _ _ W
     W _ _ B
      B B B W
     W W W W
    END_OF_BOARD
    Board.new(bs)
  end
  
end