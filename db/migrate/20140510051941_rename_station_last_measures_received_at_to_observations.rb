class RenameStationLastMeasuresReceivedAtToObservations < ActiveRecord::Migration
  def change
    rename_column :stations, :last_measure_received_at, :last_observation_received_at
  end
end
