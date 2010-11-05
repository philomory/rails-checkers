class GamesController < ApplicationController
  # GET /games
  # GET /games.xml
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

  # GET /games/1
  # GET /games/1.xml
  def show
    @game = Game.find(params[:id])
    @moves = current_user_moves? ? @game.available_moves : {}
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game }
    end
  end
  
  # POST /games/1/move
  # POST /games/1/move.xml
  def move
    game = Game.find(params[:id])
    respond_to do |format|
      if game.move(current_user,params[:move_string])
        format.html { redirect_to game_path(game), :notice => 'Move accepted.' }
        format.xml  { render :xml => game }
      else
        format.html { redirect_to game_path(game), :alert => game.errors.full_messages.to_sentence }
        format.xml  { render :xml => game.errors }
      end
    end
  end
  
  def available_moves
    game = Game.find(params[:id])
    respond_to do |format|
      if current_user_moves?(game)
        format.json { render :json => game.available_moves }
      else
        format.json { render :json => false }
      end
    end
  end
  
  def current_user_moves?(game=@game)
    game.result_is_ongoing? && game.player_to_move == current_user
  end
  helper_method :current_user_moves?
  
end
