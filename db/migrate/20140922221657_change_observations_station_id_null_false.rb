class ChangeObservationsStationIdNullFalse < ActiveRecord::Migration
  def change
    change_column_null :observations, :station_id, false
  end
end
