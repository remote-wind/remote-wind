class AddStatusToStation < ActiveRecord::Migration
  def change
    add_column :stations, :status, :integer, default: 0
    add_index :stations, :status
  end
end
