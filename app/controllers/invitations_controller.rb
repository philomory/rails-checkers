class InvitationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  
  # GET /invitations
  # GET /invitations.xml
  def index
    @invitations = Invitation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invitations }
    end
  end

  # GET /invitations/1
  # GET /invitations/1.xml
  def show
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invitation }
    end
  end

  # GET /invitations/new
  # GET /invitations/new.xml
  def new
    @invitation = Invitation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invitation }
    end
  end

  # POST /invitations
  # POST /invitations.xml
  def create
    @invitation = Invitation.create(params[:invitation])
    @invitation.issuer = current_user
    respond_to do |format|
      if @invitation.save
        format.html { redirect_to(@invitation, :notice => 'Invitation was successfully created.') }
        format.xml  { render :xml => @invitation, :status => :created, :location => @invitation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.xml
  def destroy
    @invitation = Invitation.find(params[:id])
    respond_to do |format|
      if [@invitation.issuer, @invitation.recipient].include?(current_user)
        @invitation.destroy
        format.html { redirect_to(invitations_url, :notice => "Invitation cancelled.") }
        format.xml  { head :ok }
      else
        format.html { redirect_to invitations_path, :alert => "This invitation is not yours to cancel." }
        format.xml  { head :not_authorized }
      end
    end
  end
  
  # POST /invitations/1/accept
  # POST /invitations/1/accept.xml
  def accept
    @invitation = Invitation.find(params[:id])
    respond_to do |format|
      if (@game = @invitation.accept(current_user,params[:game_options]))
        format.html { redirect_to(@game, :notice => 'A new game has begun. Have fun!') }
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { redirect_to(invitations_path, :alert => @invitation.errors.full_messages.to_sentence) }
        format.xml  { head :not_authorized }
      end
    end
  end
  
end
