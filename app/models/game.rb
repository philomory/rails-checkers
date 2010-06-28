class Game < ActiveRecord::Base
  belongs_to :player1, :class_name => 'User'
  belongs_to :player2, :class_name => 'User'
  has_many :moves
  
  enum_attr :result, %w{ongoing white_elim white_lock white_give black_elim black_lock black_give abandoned} do
    label :ongoing    => 'This game is ongoing'
    label :white_elim => 'White wins by eliminating black'
    label :white_lock => 'White wins by black not being able to move'
    label :white_give => 'White wins by black conceeding'
    label :black_elim => 'Black wins by eliminating white'
    label :black_lock => 'Black wins by white not being able to move'
    label :black_give => 'Black wins by white conceeding'
    label :abandoned  => 'This game was abandoned' 
  end
  
  validates_presence_of :player1, :player2
  validates_presence_of :board_string
  
  validate do |game| 
    errors[:base] << "Player 1 cannot be the same as Player 2" if game.player1 == game.player2
  end
  
  def board
    Board.new(self.board_string)
  end
  
  def player_for_color(color)
    case color
    when :white then player1
    when :black then player2
    else raise(ArgumentError,'Color must be :black or :white.')
    end
  end
  
  def color_for_player(user)
    case user.id
    when player1_id then :white
    when player2_id then :black
    end
  end
  
  def color_to_move
    (moves.size % 2 == 0) ? :white : :black
  end

  def other_color(color)
    case color
    when :white then :black
    when :black then :white
    end
  end

  def player_to_move
    player_for_color(color_to_move)
  end

  def process_move_string(move_string)
    color = color_to_move
    match_data = move_string.match(/^([0-7])([0-4])(.*)$/)
    raise(ArgumentError, 'Malformed move string') unless match_data
    rank, file, remainder = match_data.captures
    rank = rank.to_i; file = file.to_i
    case remainder
    when /^m(nw|ne|se|sw)$/
      direction = $~[1].intern # Beware: Magic variable!
      action = { :move => direction }
    when /^j((?:nw|ne|se|sw)+)$/
      directions = $~[1] # Beware: Magic variable!
      directions = directions.scan(/../).map(&:intern)
      action = { :jump => directions }
    else
      raise(ArgumentError, 'Malformed move string')
    end
    [color, rank, file, action]
  end

  def move(move_string)
    return false unless result_is_ongoing?
    args = process_move_string(move_string)
    new_board_string = board.do_take_turn(*args).position_string
    self.board_string = new_board_string
    self.moves.create(:move_string => move_string)
    self.elimination_check
    self.no_moves_check(color_to_move) if result_is_ongoing?
  end  

  def elimination_check
    case board.winner
    when :white then self.result = :white_elim
    when :black then self.result = :black_elim
    end
  end
  
  def no_moves_check(color)
    b = board
    locked = !(b.move_available?(color) or b.jump_available?(color))
    self.result = "#{other_color(color)}_lock" if locked
  end
  
  def conceed(color)
    return false unless result_is_ongoing?
    self.result = "#{other_color(color)}_give"
  end
  
end
