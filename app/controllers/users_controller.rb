class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => :invite
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by_username(params[:id])
  end
  
  def invite
    recipient = User.find_by_username(params[:id])
    @invitation = Invitation.new(:recipient => recipient)
    
    respond_to do |format|
      format.html { render 'invitations/new' }
      format.xml  { render :xml => @invitation  }
    end
  end
  
end