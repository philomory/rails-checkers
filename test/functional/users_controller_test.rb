require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should show user" do
    get :show, :id => User.make.to_param
    assert_response :success
  end
  
end