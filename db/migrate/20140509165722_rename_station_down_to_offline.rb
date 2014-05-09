class RenameStationDownToOffline < ActiveRecord::Migration
  def change
    rename_column :stations, :down, :offline
  end
end
