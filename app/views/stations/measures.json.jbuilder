json.measures do
  json.array!(@measures) do |m|
    json.extract! m, :id, :speed, :max_wind_speed, :min_wind_speed, :created_at
    json.tstamp (m.created_at.to_i+Time.zone.utc_offset) * 1000
  end
end
json.station(@station, :id, :latitude, :longitude, :name, :slug)
