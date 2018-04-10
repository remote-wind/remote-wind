class AddLatestObservationToStation < ActiveRecord::Migration
  def change
    add_reference :stations, :latest_observation,
       index: true, foreign_key: false

    # sets latest_observation for all existing stations
    Station.find_each(batch_size: 100) do |s|
      o = s.observations.last
      s.update(latest_observation: o) if o
    end
  end
end
