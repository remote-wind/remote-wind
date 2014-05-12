class AddIndicesToStations < ActiveRecord::Migration
  def change
    add_index :stations, :offline
    add_index :stations, :updated_at
    add_index :stations, :show
    add_index :stations, :last_observation_received_at
  end
end