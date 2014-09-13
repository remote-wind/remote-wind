class RenameStationDownToOffline < ActiveRecord::Migration
  def change
    rename_column :stations, :down, :offline if Station.column_names.include?('down')
  end
end
