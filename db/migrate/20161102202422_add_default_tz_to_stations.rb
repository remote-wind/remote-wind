class AddDefaultTzToStations < ActiveRecord::Migration
  def change
    Station.where(timezone: nil).update_all(timezone: 'Europe/Stockholm')
    change_column :stations, :timezone, :string, default: 'Europe/Stockholm'
  end
end
