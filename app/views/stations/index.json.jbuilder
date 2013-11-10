json.array!(@stations) do |station|
  json.extract! station, 
  json.url station_url(station, format: :json)
end
