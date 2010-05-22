class Game < ActiveRecord::Base
  belongs_to :player1, :class_name => 'User'
  belongs_to :player2, :class_name => 'User'
  
  validates_presence_of :player1, :player2
  validate do |game| 
    errors[:base] << "Player 1 cannot be the same as Player 2" if game.player1 == game.player2
  end
  
end
