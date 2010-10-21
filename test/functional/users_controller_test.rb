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
  
  test "should invite user" do
    sign_in User.make
    recipient = User.make
    get :invite, :id => recipient.to_param

    assert_response :success
    assert_equal recipient, assigns(:invitation).recipient
  end
  
end