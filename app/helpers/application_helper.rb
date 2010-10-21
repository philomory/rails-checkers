module ApplicationHelper
  
  def play_square?(row,col)
    ((row + col) % 2 == 1 )
  end
  
  def square_class(row,col)
    play_square?(row,col) ? 'play_square' : 'non_play_square'
  end
  
  def square_id(row,col)
    "rank:#{row},file:#{col/2}"
  end
  
  def checkers_square(row,col,board_string,available_moves)
    if play_square?(row,col)
      rank, file = row, col/2
      tag_class = 'play_square'
      tag_class += ' move_square' if available_moves.key?([rank,file])
      content_tag(:td,board_string[rank*4 + file], :class => tag_class, :id => square_id(row,col))
    else
      tag(:td,:class => 'non_play_square')
    end
  end
    
end
