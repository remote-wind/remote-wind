class CreateStations < ActiveRecord::Migration
  def self.up
    create_table :stations do |t|
      t.string :name
      t.string :hw_id
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end

  def self.down
    drop_table :stations
  end
end
