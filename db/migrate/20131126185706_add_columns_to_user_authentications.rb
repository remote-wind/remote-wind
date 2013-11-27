class AddColumnsToUserAuthentications < ActiveRecord::Migration
  def change
    add_column :user_authentications, :provider_name, :string
  end
end
