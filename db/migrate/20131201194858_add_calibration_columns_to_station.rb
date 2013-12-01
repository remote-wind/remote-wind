class AddCalibrationColumnsToStation < ActiveRecord::Migration
  def change
    add_column :stations, :speed_calibration, :float, default: 1
  end
end