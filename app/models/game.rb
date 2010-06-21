class Game < ActiveRecord::Base
  belongs_to :player1, :class_name => 'User'
  belongs_to :player2, :class_name => 'User'
  
  validates_presence_of :player1, :player2
  validates_presence_of :board_string
  
  validate do |game| 
    errors[:base] << "Player 1 cannot be the same as Player 2" if game.player1 == game.player2
  end
  
  def board
    Board.new(self.board_string)
  end
  
end
