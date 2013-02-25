class AddDownToStations < ActiveRecord::Migration
  def change
    add_column :stations, :down, :boolean
  end
end
