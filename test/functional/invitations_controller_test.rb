require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invitations)
  end

  test "should get new if logged in" do
    sign_in User.make
    get :new
    assert_response :success
  end

  test "should not get new if not logged in" do
    get :new
    assert_redirected_to new_user_session_path
  end

  test "should create invitation when logged in" do
    sign_in User.make
    assert_difference('Invitation.count') do
      post :create, :invitation => Invitation.plan
    end

    assert_redirected_to invitation_path(assigns(:invitation))
  end

  test "should not create invitation when not logged in" do
    assert_no_difference('Invitation.count') do
      post :create, :invitation => Invitation.plan
    end

    assert_redirected_to new_user_session_path
  end
  
  test "created invitation should always have logged in user as issuer, regardless of params" do
    user1 = User.make
    user2 = User.make
    user3 = User.make
    sign_in user1
    plan = Invitation.plan(:issuer => user2, :recipient => user3)
    post :create, :invitation => plan
    invite = Invitation.last
    
    assert_equal user1, invite.issuer, "Invitation should be issued by logged-in user"
  end  
  
  test "should show invitation" do
    invite = Invitation.make
    get :show, :id => invite.to_param
    assert_response :success
  end

  test "should destroy invitation when logged in as issuer" do
    invite = Invitation.make
    sign_in invite.issuer
    assert_difference('Invitation.count', -1) do
      delete :destroy, :id => invite.to_param
    end

    assert_redirected_to invitations_path
  end

  test "should destroy invitation when logged in as recipient" do
    invite = Invitation.make(:recipient => User.make)
    sign_in invite.recipient
    assert_difference('Invitation.count', -1) do
      delete :destroy, :id => invite.to_param
    end
  end

  test "should not destroy invitation if not logged in" do
    invite = Invitation.make
    assert_no_difference('Invitation.count') do
      delete :destroy, :id => invite.to_param
    end

    assert_redirected_to new_user_session_path
  end

  test "should not destroy invitaton when logged in as unrelated user" do
    third_party = User.make
    invite = Invitation.make
    sign_in third_party
    assert_no_difference('Invitation.count') do
      delete :destroy, :id => invite.to_param
    end
    
    assert_redirected_to invitations_path
    assert_not_nil flash[:alert]
  end
  
  test "should accept an invitation when logged in as the recipient" do
    invite = Invitation.make
    sign_in invite.recipient
    assert_difference('Game.count') do
      post :accept, :id => invite.to_param
    end
    
    assert_redirected_to game_path(assigns(:game))
  end

  test "should not accept an invitation when not logged in" do
    invite = Invitation.make
    assert_no_difference('Game.count') do
      post :accept, :id => invite.to_param
    end
    
    assert_redirected_to new_user_session_path
  end

  test "should not accept a closed invitation when logged in as someone other than the recipient" do
    invite = Invitation.make
    sign_in User.make
    assert_no_difference('Game.count') do
      post :accept, :id => invite.to_param
    end
    
    assert_not_nil flash[:alert]
    assert_redirected_to invitations_path
  end

end
