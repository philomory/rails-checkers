class Move < ActiveRecord::Base
  belongs_to :game, :counter_cache => true
  before_create { self.ply = game.moves.size } # + 1 for the move being created, -1 for 0 based indexing
end
