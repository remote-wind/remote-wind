namespace :demo do
  desc "Seed with a bunch of random measurements"
  task random_measures: :environment do
    stations = Station.all
    stations.each do |station|
      Random.new.rand(0..10).times do
        speed = Random.new.rand(0..30)
        station.measures.create({
            :station_id => station.id,
            :direction => Random.new.rand(0..360),
            :speed => speed,
            :min_wind_speed => Random.new.rand(0..speed),
            :max_wind_speed => Random.new.rand(speed..speed + 15)
        })
      end
    end
  end
end
