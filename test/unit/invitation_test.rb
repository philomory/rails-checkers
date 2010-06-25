require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "An invitation can be created" do
    assert_difference('Invitation.count') do
      invite = Invitation.make
      assert !invite.new_record?, "#{invite.errors.full_messages.to_sentence}"
    end
  end
  
  test "An invitation must have an issuer" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Invitation.make(:issuer => nil)
    end
  end
  
  test "An invitation must inform about the first move" do
    assert_raises(ActiveRecord::RecordInvalid) { Invitation.make(:first_move => nil) }
  end
  
  test "An invitation's first_move must be :me, :you, :choice or :random" do
    assert_nothing_raised() { Invitation.make(:first_move => :issuer) }
    assert_nothing_raised() { Invitation.make(:first_move => :recipient) }
    assert_nothing_raised() { Invitation.make(:first_move => :choice) }
    assert_nothing_raised() { Invitation.make(:first_move => :random) }
    assert_raises(EnumeratedAttribute::InvalidEnumeration) { Invitation.make(:first_move => :sdhs) }
  end
  
  test "An invitation with no recipient is open" do
    assert Invitation.make(:recipient => nil).open?, "Invitation should be open"
    refute Invitation.make(:recipient => User.make).open?, "Invitation should not be open"
  end
  
  test "Can get open invitations" do
    3.times { Invitation.make(:recipient => User.make) }
    4.times { Invitation.make(:recipient => nil)       }
    assert_equal 4, Invitation.open.count
  end
  
  test "Recipient can accept invitation" do
    invite = Invitation.make
    user = invite.recipient
    assert invite.accept(user), "Invitation should be accepted"
  end
    
  test "Non-recipient cannot accept invitation" do
    invite = Invitation.make
    refute invite.accept(User.make), "Invitation should not be accepted"
  end
  
  test "any user should be able to accept an open invitation" do
    invite = Invitation.make(:open, :recipient => nil)
    assert invite.accept(User.make), "Any use should be able to accept open invitation"
  end
  
  test "if first_move is :choice in the invitation, acceptor must supply a :first_move" do
    invite = Invitation.make(:open, :first_move => :choice)
    refute invite.accept(User.make)
    assert invite.accept(User.make,:first_move => :random)
  end
  
  test "recipient-supplied first_move must be :random, :issuer or :recipient" do
    user = User.make
    assert Invitation.make(:open, :first_move => :choice).accept(user,:first_move => :random)
    assert Invitation.make(:open, :first_move => :choice).accept(user,:first_move => :issuer)
    assert Invitation.make(:open, :first_move => :choice).accept(user,:first_move => :recipient)
    refute Invitation.make(:open, :first_move => :choice).accept(user,:first_move => :choice) 
  end
  
  test "accepting an invitation returns a game" do
    invite = Invitation.make(:open)
    result = invite.accept(User.make)
    assert_kind_of Game, result
    assert !result.new_record?, "#{result.errors.full_messages.to_sentence}"
  end
  
  test "player1 and player2 are assigned correctly for :first_move => :issuer" do
    invite = Invitation.make(:first_move => :issuer)
    game = invite.accept(invite.recipient)
    assert_equal invite.issuer, game.player1, "Issuer should be player 1"
    assert_equal invite.recipient, game.player2, "Recipient should be player 2"
  end
  
  test "players are assigned correctly for :first_move => :recipient" do
    invite = Invitation.make(:first_move => :recipient)
    game = invite.accept(invite.recipient)
    assert_equal invite.recipient, game.player1, "Recipient should be player 1"
    assert_equal invite.issuer, game.player2, "Issuer should be player 2"
  end
  
  test "after an invitation is accepted, it is destroyed" do
    invite = Invitation.make
    invite.accept(invite.recipient)
    assert invite.destroyed?, "Accepted invitation should be removed from the database."
  end
  
end
