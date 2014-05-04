json.(measure, :id, :speed, :direction, :max_wind_speed, :min_wind_speed)
json.tstamp station.time_to_local(measure.created_at).to_i
json.created_at json.created_at( station.time_to_local(measure.created_at).iso8601 )