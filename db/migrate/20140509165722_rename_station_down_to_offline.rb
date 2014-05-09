class RenameStationDownToOffline < ActiveRecord::Migration
  def change
    rename_column :stations, :offline, :offline
  end
end
