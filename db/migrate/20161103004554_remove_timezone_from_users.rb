class RemoveTimezoneFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :timezone
  end
end
