class Board
  class MoveError < StandardError; end
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
  
  def initialize_copy(original)
    @padded_board_string = original.padded_board_string.dup
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
    index,dir = process_move_args(*args)
    self[index].travels?(dir) && self[index + MOVE[dir]].empty?
  end
  
  def do_move(*args)
    raise(MoveError, "Requested move is not legal!") unless can_move?(*args)
    index, dir = process_move_args(*args)
    @padded_board_string[index + MOVE[dir]] = chr(index)
    @padded_board_string[index] = :_
    index + MOVE[dir]
  end
  
  def can_jump?(*args)
    index, dir = process_move_args(*args)
    jumper = self[index]
    victim = self[index + MOVE[dir]]
    target = self[index + 2*MOVE[dir]] 
    jumper.travels?(dir) && victim.enemy?(jumper) && target.empty?
  end
  
  def do_jump(*args)
    raise(MoveError, "Requested jump is not legal!") unless can_jump?(*args)
    index, dir = process_move_args(*args)
    @padded_board_string[index + 2*MOVE[dir]] = chr(index)
    @padded_board_string[index] = :_
    @padded_board_string[index + MOVE[dir]] = :_
  end
    
  def can_multi_jump?(*args)
    !!check_multi_jump(*args)
  end
  
  def do_multi_jump(*args)
    result, new_index = check_multi_jump(*args)
    if (result)
      @padded_board_string = result.padded_board_string
      new_index
    else
      raise(MoveError, "Requested series of jumps is not legal!")
    end
  end
  
  def can_take_turn?(*args)
    color,index,action = process_turn_args(*args)
    return false unless self[index].color == color
    if (dir = action[:move])
      can_move?(index,dir) and not jump_available?(color)
    else
      dirs = Array(action[:jump])
      board, final_index = check_multi_jump(index,*dirs)
      board and not [:nw,:ne,:sw,:se].any? {|dir| board.can_jump?(final_index,dir) }
    end
  end
  
  def do_take_turn(*args)
    raise(MoveError,"Request turn is not legal!") unless can_take_turn?(*args)
    _,index,action = process_turn_args(*args)
    new_index = if (dir = action[:move])
      do_move(index,dir)
    else
      dirs = Array(action[:jump])
      do_multi_jump(index,*dirs)
    end
    crown_if_needed(new_index)
    self
  end
  
  def move_available?(color)
    if color == :white
      @padded_board_string =~ /_.{3,4}[wW]|W.{3,4}_/
    elsif color == :black
      @padded_board_string =~ /_.{3,4}B|[bB].{3,4}_/
    end
  end
  
  def available_moves(color)
    # These regular expressions are used for checking each of the directions of movement.
    # Where the board string matches one of them, there is a valid move in the appropriate
    # direction.
    #
    # The two colors are different because black pawns and white pawns move in opposite
    # directions, though Kings all move the same way.
    # 
    # The expressions need to be checked as zero-width lookahead capturing groups because 
    # otherwise we can't have overlapping matches - no two adjacent pieces would be able
    # to move in the same direction, among other problems. They're written bare and
    # interpolated into a ZWLA for what I thought was clarity, but I'm not sure it helps
    # and may change it back.
    ne,nw,se,sw = case color
    when :white then %w{ W...._ W..._ _...[wW] _....[wW] }
    when :black then %w{ [bB]...._ [bB]..._ _...B _....B }
    end.map {|s| /(?=(#{s}))/ }
    
    # Use the private 'scan' method, shared with available_jumps, to generate the hash.
    scan(ne,nw,se,sw)
  end
  
  def available_jumps(color)
    # See the comments in available_moves for clarification on the intent here.
    ne,nw,se,sw = case color
    when :white then %w{ W....[bB]...._ W...[bB]..._ _...[bB]...[wW] _....[bB]....[wW] }
    when :black then %w{ [bB]....[wW]...._ [bB]...[wW]..._ _...[wW]...B _....[wW]....B }
    end.map {|s| /(?=(#{s}))/ }
    
    scan(ne,nw,se,sw)
  end
  
  def available_actions(color)
    if (result = available_jumps(color)).any?
      result[:type] = :jump
    elsif (result = available_moves(color)).any? 
      result[:type] = :move
    else
      result = nil
    end
    result
  end
  
  
  # Considered using a more legible iterative approach here, but the regex approach
  # is _twenty-eight times faster_. Considering that this is an operation that will
  # have to be performed quite frequently, totally worth it. Anyway, the regex is
  # fairly legible anyway.
  def jump_available?(color)
    if color == :white
      @padded_board_string =~ /_...[bB]...[wW]|_....[bB]....[wW]|W...[bB]..._|W....[bB]...._/
    elsif color == :black
      @padded_board_string =~ /[bB]...[wW]..._|[bB]....[wW]...._|_...[wW]...B|_....[wW]....B/
    end
  end
    
  def winner
    s = @padded_board_string
    white = (s =~ /w/i); black = (s =~ /b/i)
    if     white and not black then :white
    elsif  black and not white then :black
    end
  end
  
  def to_s
    position_string
  end
    
  # A compact string suitable for passing to Board.new to regenerate
  # the current board.  
  def position_string
    # Oddly, String#delete is non-destructive, unlike Array#delete
    @padded_board_string.delete('*').scan(/..../).reverse.join
  end
  
  def ==(other)
    position_string == other.position_string
  end
  
  protected
  def padded_board_string
    @padded_board_string.dup
  end  
  
  private
  def process_move_args(*args)
    case args.length
    when 2 then args
    when 3 then [padded_index(args[0],args[1]),args[2]]
    else raise(ArgumentError)
    end
  end
  
  def process_multi_args(*args)
    if !(args[0].is_a? Integer)
      raise(ArgumentError,"Must pass index or rank and file, and a series of symbols")
    elsif args[1].is_a? Symbol
      [args[0],args[1..-1]]
    elsif args[1].is_a? Integer
      [padded_index(args[0],args[1]), args[2..-1]]
    else
      raise(ArgumentError,"Must pass index or rank and file, and a series of symbols")
    end
  end
  
  def process_turn_args(color,*args)
    raise(ArgumentError) unless [:white,:black].include?(color)
    index, action = if (args.length == 2 && args[0].kind_of?(Integer) && args[1].kind_of?(Hash))
      args
    elsif (args.length == 3 && args[0].kind_of?(Integer) && args[1].kind_of?(Integer) && args[2].kind_of?(Hash))
      [padded_index(args[0],args[1]),args[2]]
    else
      raise(ArgumentError)
    end
    raise(ArgumentError) unless action[:move] || action[:jump]
    raise(ArgumentError) if action[:move] && action[:jump]
    [color,index,action]
  end
  
  def check_multi_jump(*args)
    index, dirs = process_multi_args(*args)
    if dirs.empty?
      false
    else
      ary = [self.dup,index]
      dirs.inject(ary) do |ary,dir|
        b,i = *ary
        if b.can_jump?(i,dir)
          b.do_jump(i,dir)
          [b,i+2*MOVE[dir]]
        else
          return nil
        end
      end
    end
  end
  
  
  
  # Scan the board string for regexen representing moves in the four possible directions.
  def scan(ne,nw,se,sw)
    # TODO: Refactor this to be either more abstract, or less. At the moment it's in an
    # ugly middle-ground that is not quite straightforward enough to justify it's verbosity,
    # nor DRY enough to justify its complexity. That being said, 90% of the work is done,
    # so only 90% is left.
    
    # This method requires some degree of explanation.
    
    # First, set up a hash to hold the moves.
    moves = {}

    # Now we run each regex across the string using scan. The purpose of the
    # 'off' parameter is to indicate whether we are looking at the beginning of
    # the match or the end. Since we want the location of the piece that's moving,
    # not the location of the square it's moving to, for north (left-to-right)
    # movement we use 0, for south (right-to-left) we use 1.
    [[ne,:ne,0],[nw,:nw,0],[se,:se,1],[sw,:sw,1]].each do |regx,dir,off|

      # Here we use scan with our passed in regex.
      @padded_board_string.scan(regx) do

        # Scan, unfortunately, passes an array of strings to the block rather than
        # a MatchData object. Fortunately, our MatchData is available in the magic
        # variable $~. We check the offsets of the first capturing group, using the
        # off parameter described above. We subtract one when checking the end of the
        # match because we want the last char in the match while the offset method
        # gives us the first char after the match.
        index = $~.offset(1)[off] - off

        # Here we're just converting from string index into rank & file coordinates
        # and storing the results appropriately.
        coords = coords_for_index(index)
        moves[coords] ||= []
        moves[coords] << dir
      end
    end
    moves
  end
  
  
  def padded_index(rank,file)
    37 - (rank * 4.5).ceil + file
  end
  
  def coords_for_index(index)
    rank = ((36 - index) / 4.5).ceil # Kinda a stupid formula, but it works.
    file = index + (rank * 4.5).ceil - 37
    [rank,file]
  end
  
  
  def chr(index)
    @padded_board_string[index]
  end
  
  def crown_if_needed(index)
    if self[index].white_pawn? && index.between?(5,8) # bottom row
      @padded_board_string[index] = :W
    elsif self[index].black_pawn? && index.between?(37,40) # top row
      @padded_board_string[index] = :B
    end
  end
  
  # Only any good with string of length 32
  def pad_string(str)
    str.scan(/..../).reverse.join.dup.insert(0,'*****').insert(9,'*').insert(18,'*').insert(27,'*').insert(36,'*').insert(41,'*****')
  end
  
  Square = Struct.new(:chr,:name,:state,:color,:crown) do
    def white?; color == :white; end
    def black?; color == :black; end
    def enemy?(other); (black? && other.white?) || (white? && other.black?); end
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