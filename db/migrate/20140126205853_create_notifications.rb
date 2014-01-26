class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :subject
      t.string :key
      t.text :message
      t.belongs_to :user
    end
  end
end
