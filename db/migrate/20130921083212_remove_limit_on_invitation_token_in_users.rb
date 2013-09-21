class RemoveLimitOnInvitationTokenInUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :invitation_token, :string
    end
  end
end
