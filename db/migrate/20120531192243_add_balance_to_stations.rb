class AddBalanceToStations < ActiveRecord::Migration
  def self.up
    add_column :stations, :balance, :float
  end

  def self.down
    remove_column :stations, :balance
  end
end
