json.array!(@stations) do |station|
  json.extract! station, :id, :name, :slug, :latitude, :longitude
  json.url station_url(station, format: :json)
  json.path station_path(station)
end
