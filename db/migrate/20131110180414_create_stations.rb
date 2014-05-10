class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :name
      t.string :hw_id
      t.float :latitude
      t.float :longitude
      t.float :balance
      t.boolean :offline
      t.string :timezone
      t.references :user, index: true

      t.timestamps
    end
    add_index :stations, :hw_id, unique: true
  end
end
