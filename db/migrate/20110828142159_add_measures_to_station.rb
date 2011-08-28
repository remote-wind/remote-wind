class AddMeasuresToStation < ActiveRecord::Migration
  def self.up
    add_column :measures, :station_id, :integer
  end

  def self.down
    remove_column :measures, :station_id
  end
end
