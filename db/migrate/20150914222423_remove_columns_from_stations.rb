class RemoveColumnsFromStations < ActiveRecord::Migration
  def change
    remove_column :stations, :last_observation_received_at
  end
end
