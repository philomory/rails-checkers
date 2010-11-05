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
      content_tag(:td, :class => tag_class, :id => square_id(row,col),
                  'data-rank' => rank, 'data-file' => file) do
        content_tag(:div,board_string[rank*4 + file])
      end
    else
      tag(:td,:class => 'non_play_square')
    end
  end
    
end
