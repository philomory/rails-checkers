require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = Game.make
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should show game" do
    get :show, :id => @game.to_param
    assert_response :success
  end
  
  test "should allow move for appropriate user" do
    sign_in @game.player1
    assert_difference('@game.moves.count') do
      post :move, :id => @game.to_param, :move_string => '20mse'
    end

    assert_redirected_to game_path(@game)
    assert_not_nil flash[:notice], flash
  end

  test "should not allow move inappropriate player" do
    sign_in User.make
    assert_no_difference('@game.moves.count') do
      post :move, :id => @game.to_param, :move_string => '20mse'
    end
    
    assert_redirected_to game_path(@game)
    assert_not_nil flash[:alert]
  end

end
