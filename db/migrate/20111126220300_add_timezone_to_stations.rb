class AddTimezoneToStations < ActiveRecord::Migration
  def self.up
    add_column :stations, :timezone, :string
  end

  def self.down
    remove_column :stations, :timezone
  end
end
