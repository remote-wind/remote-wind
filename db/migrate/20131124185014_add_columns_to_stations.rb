class AddColumnsToStations < ActiveRecord::Migration
  def change
    add_column :stations, :balance, :float
    add_column :stations, :down, :boolean
  end
end
