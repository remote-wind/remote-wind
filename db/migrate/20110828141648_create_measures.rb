class CreateMeasures < ActiveRecord::Migration
  def self.up
    create_table :measures do |t|
      t.float :speed
      t.float :direction

      t.timestamps
    end
  end

  def self.down
    drop_table :measures
  end
end
