json.measure do
  json.extract! m, :id, :speed, :max_wind_speed, :min_wind_speed, :direction
  json.tstamp @station.time_to_local(m.created_at).to_i
  json.created_at @station.time_to_local(m.created_at).to_s
end