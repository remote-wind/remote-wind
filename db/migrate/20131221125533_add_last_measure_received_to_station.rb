class AddLastMeasureReceivedToStation < ActiveRecord::Migration
  def change
    add_column :stations, :last_measure_received_at, :datetime
  end
end
