class AddSpeedCalibrationToMeasures < ActiveRecord::Migration
  def change
    add_column :measures, :speed_calibration, :float
  end
end
