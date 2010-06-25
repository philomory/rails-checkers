class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.references :issuer
      t.references :recipient
      t.string :first_move

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
