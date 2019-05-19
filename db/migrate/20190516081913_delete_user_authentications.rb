class DeleteUserAuthentications < ActiveRecord::Migration
  def self.up
    User.joins(:authentications)
        .where(encrypted_password: nil)
        .find_each do |user|
          user.send_reset_password_instructions
        end
    drop_table :user_authentications
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
