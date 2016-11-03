class RemoveBooleanColumnsFromStations < ActiveRecord::Migration
  def change
    # needed if migration is reversed
    if Station.column_names.includes?("offline")
      Station.where(offline: true).update_all(
        status: Station.statuses[:unresponsive] # should be the integer mapping
      )
      Station.where(offline: false).update_all(
        status: Station.statuses[:active] # should be the integer mapping
      )
    end
    remove_column(:stations, :offline)
    remove_column(:stations, :show)
  end
end
