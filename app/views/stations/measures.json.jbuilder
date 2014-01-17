json.measures do
  json.array!(@measures) do |m|
    json.extract! m, :id, :speed, :max_wind_speed, :min_wind_speed, :direction
    json.tstamp m.station.time_to_local(m.created_at).to_i
    json.created_at m.station.time_to_local(m.created_at).to_s
  end
end
json.station(@station, :id, :latitude, :longitude, :name, :slug)
