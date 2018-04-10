class RemoveLatestObservations < ActiveRecord::Migration
  def change
    drop_table :latest_observations
  end
end
