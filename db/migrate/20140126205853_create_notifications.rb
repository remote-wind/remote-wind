class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :event
      t.text :message
      t.belongs_to :user
    end
  end
end