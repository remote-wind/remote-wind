namespace :demo do
  desc "Seed with a bunch of random measurements"
  task random_measures: :environment do
    stations = Station.all
    t = Time.now - 10000
    stations.each do |station|
      Random.new.rand(0..10).times do
        speed = Random.new.rand(0..30)
        measure = station.measures.create({
            :station_id => station.id,
            :direction => Random.new.rand(0..360),
            :speed => speed,
            :min_wind_speed => Random.new.rand(0..speed),
            :max_wind_speed => Random.new.rand(speed..speed + 15)
        })
        measure.created_at = t + 1000
      end
    end
  end
end
