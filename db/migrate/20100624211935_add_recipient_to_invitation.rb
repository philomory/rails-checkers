class AddRecipientToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :recipient, :references
  end

  def self.down
    remove_column :invitations, :recipient
  end
end
