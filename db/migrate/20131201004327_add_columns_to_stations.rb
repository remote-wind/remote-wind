class AddColumnsToStations < ActiveRecord::Migration
  def change
    add_column :stations, :show, :boolean, default: true
  end
end