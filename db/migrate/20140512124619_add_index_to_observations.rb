class AddIndexToObservations < ActiveRecord::Migration
  def change
    add_index :observations, :created_at
  end
end