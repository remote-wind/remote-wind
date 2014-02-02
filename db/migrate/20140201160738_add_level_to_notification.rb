class AddLevelToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :level, :integer
  end
end
