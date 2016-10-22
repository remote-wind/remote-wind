class AddSamplingRateToStations < ActiveRecord::Migration
  def change
    # The sampling_rate expessed in seconds
    # 300s = 5min
    add_column :stations, :sampling_rate, :integer, default: 300
  end
end
