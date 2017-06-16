class CreateLatestObservations < ActiveRecord::Migration
  def change
    create_table :latest_observations do |t|
      t.references :station, index: true, foreign_key: true
      t.float :speed
      t.float :direction
      t.float :max_wind_speed
      t.float :min_wind_speed
      t.float :temperature
      t.float :speed_calibration

      t.timestamps null: false
    end
  end
end
