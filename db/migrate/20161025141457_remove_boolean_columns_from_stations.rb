class RemoveBooleanColumnsFromStations < ActiveRecord::Migration
  def change
    Station.where(offline: true).update_all(status: :unresponsive)
    Station.where(offline: false).update_all(status: :active)
    remove_column(:stations, :offline)
    remove_column(:stations, :show)
  end
end
