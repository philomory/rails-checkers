class Invitation < ActiveRecord::Base
  belongs_to :issuer, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validates_presence_of :issuer, :first_move
  enum_attr :first_move, %w{issuer recipient choice random}
  
  def open?
    recipient.nil?
  end
  
  scope :open, where(:recipient_id => nil)
  
  def accept(user,options = {})
    if open? or user == recipient
      f_m = first_move_is_choice? ? options[:first_move] : first_move
      if f_m == :random 
        f_m = rand(2) == 0 ? :issuer : :recipient
      end
      
      player1, player2 = case f_m
      when :issuer then [issuer, user]
      when :recipient then [user, issuer]
      end

      game = Game.create(:player1 => player1, :player2 => player2, 
                         :board_string => Board::DEFAULT_BOARD_STRING)
      
      if game.new_record?
        false
      else
        self.destroy
        game
      end
    end 
  end
  
  
end
