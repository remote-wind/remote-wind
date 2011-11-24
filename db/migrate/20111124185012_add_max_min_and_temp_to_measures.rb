class AddMaxMinAndTempToMeasures < ActiveRecord::Migration
  def self.up
    add_column :measures, :max_wind_speed, :float
    add_column :measures, :min_wind_speed, :float
    add_column :measures, :temperature, :float
  end

  def self.down
    remove_column :measures, :temperature
    remove_column :measures, :min_wind_speed
    remove_column :measures, :max_wind_speed
  end
end
