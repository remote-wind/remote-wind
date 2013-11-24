class CreateMeasures < ActiveRecord::Migration
  def change
    create_table :measures do |t|
      t.belongs_to :station, index: true
      t.float :speed
      t.float :direction
      t.float :max_wind_speed
      t.float :min_wind_speed
      t.float :temperature

      t.timestamps
    end
  end
end
