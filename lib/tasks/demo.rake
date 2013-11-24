namespace :demo do
  desc "Seed with a bunch of random measurements"
  task random_measures: :environment do

    puts "Seeding db with random measurements"
    stations = Station.all

    stations.each do |station|
      rnd = Random.new.rand(5..35)
      t = Time.now - (rnd * 1000)
      rnd.times do
        speed = Random.new.rand(0..30)
        measure = station.measures.create({
            :station_id => station.id,
            :direction => Random.new.rand(0..360),
            :speed => speed,
            :min_wind_speed => Random.new.rand(0..speed),
            :max_wind_speed => Random.new.rand(speed..speed + 15)
        })
        t = t + 1000
        measure.created_at = t
        measure.save!
        puts measure.inspect
      end
    end
  end
end
