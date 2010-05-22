class Board


  
  DEFAULT_BOARD_STRING = "wwwwwwwwwwww________bbbbbbbbbbbb"
  DEFAULT_PADDED_BOARD_STRING = "*****bbbb*bbbbbbbb*________*wwwwwwww*wwww*****"
  # convert padded to unpadded: str.delete('*')
  # convert unpadded to padded: str.dup.insert(0,'*****').insert(9,'*').insert(18,'*').insert(27,'*').insert(36,'*').insert(41,'*****')
  
  def initialize(input_string=DEFAULT_BOARD_STRING)
    input_string = input_string.gsub(/\s/,'') # don't destructively modify, incase the user is hanging on to it.
    raise(ArgumentError,"Board requires a board string of length 32") unless input_string.length == 32
    raise(ArgumentError,"Board string can only contain w, W, b, B and _") if input_string =~ /[^wWbB_]/
    @padded_board_string = pad_string(input_string)
  end
  
  def rank_and_file(rank,file)
    index = padded_index(rank,file)
    self[index]
  end
  
  def [](index)
    MAPPINGS[chr(index)]
  end
  
  # call-seq:
  #   can_move?(index,direction) => true or false
  #   can_move?(rank,file,direction) => true or false
  #
  # Ask whether the given piece can move in the specified direction.
  def can_move?(*args)
    index,dir = case args.length
    when 2 then args
    when 3 then [padded_index(args[0],args[1]),args[2]]
    else raise(ArgumentError,"Must provide ")
    end
    self[index].travels?(dir) && self[index + MOVE[dir]].empty?
  end
  
  
  
  
  
  private
  def padded_index(rank,file)
    37 - (rank * 4.5).ceil + file
  end
  
  def chr(index)
    @padded_board_string[index]
  end
  
  # Only any good with string of length 32
  def pad_string(str)
    str.scan(/..../).reverse.join.dup.insert(0,'*****').insert(9,'*').insert(18,'*').insert(27,'*').insert(36,'*').insert(41,'*****')
  end
  
  # Only meant for strings of length 46
  # def unpad(str = @padded_board_string)
  #   str.delete('*') # oddly, String#delete is nondestructive, unlike Array#delete
  # end
  
  Square = Struct.new(:chr,:name,:state,:color,:crown) do
    def white?; color == :white; end
    def black?; color == :black; end
    def  king?; crown; end
    def  pawn?; occupied? and not king?; end
    def empty?; state == :empty; end
    def occupied?; state == :occupied; end
    def white_pawn?; white? and pawn?; end
    def white_king?; white? and king?; end
    def black_pawn?; black? and pawn?; end
    def black_king?; black? and king?; end
    def travels?(dir); travel_dirs.include?(dir); end
    def travel_dirs
      if     king? then [:ne,:nw,:se,:sw]
      elsif white? then [:se,:sw]
      elsif black? then [:ne,:nw]
      else              []
      end
    end
  end

  # In this case, object orientation can take a hike. Checkers pieces don't
  # need their own instance variables and methods, let alone database records.
  # There are only five possible values for a given checkers square, six if you
  # count out of bounds.  
  MAPPINGS = {
    '_' => Square.new('_',:empty,:empty).freeze,
    '*' => Square.new('*',:out_of_bounds,:out_of_bounds).freeze,
    'w' => Square.new('w',:white_pawn,:occupied,:white).freeze,
    'W' => Square.new('W',:white_king,:occupied,:white,true).freeze,
    'b' => Square.new('b',:black_pawn,:occupied,:black).freeze,
    'B' => Square.new('B',:black_king,:occupied,:black,true).freeze
  }.freeze
  
  MOVE = {
    :ne => +5,
    :nw => +4,
    :se => -4,
    :sw => -5
  }
  
  
  
  
end