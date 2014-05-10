class RenameMeasuresToObservations < ActiveRecord::Migration
  def change
    rename_table :measures, :observations
  end
end
