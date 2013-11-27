# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Setup geonames user name
Timezone::Configure.begin do |c|
  c.username = ENV['REMOTE_WIND_GEONAMES']
end

unless User.find_by_email(ENV["REMOTE_WIND_EMAIL"])

  admin = User.find_or_create_by_email(
      email: ENV["REMOTE_WIND_EMAIL"],
      password: ENV["REMOTE_WIND_PASSWORD"],
      password_confirmation: ENV["REMOTE_WIND_PASSWORD"]
  )
  admin.add_role(:admin)

  puts "Hello my new master #{ENV['REMOTE_WIND_EMAIL']}, I have created an account just for you. The password in the one you set in REMOTE_WIND_PASSWORD
 \n\n"

end

def svenne_generator

  fn = %w[johan nils carl-olof sofie anna kristina sara olof bengt tommy]
  ln1 = %w[berg wall aker holm]
  ln2 = %w[gren kvist strom stedt]

  email =  fn.sample + "." + ln1.sample + ln2.sample + "@example.com"
end

puts "Spawing random users \n"
users = (1..50).to_a.map! do
  print "."
  User.find_or_create_by_email svenne_generator
end

unless Station.any?
  puts "\nCreating stations\n"
  stations = [
      {name: 'Tegefjäll', hw_id: '354476020409714', lat: '63.4017', lon:'12.97256'},
      {name: 'Mullfjället', hw_id: '354476020409715', lat: '63.42258', lon: '12.95487'},
      {name: 'Ullådalen', hw_id: '354476020409716', lat: '63.4321', lon: '13.00011'},
      {name: 'Frösön', hw_id: '3544760204324716', lat: 63.206557, lon: 14.446625},
      {name: 'Näsbokrok', hw_id: '123123123', lat: 57.336714, lon: 12.067055 },
      {name: 'Mörbylånga N', hw_id: '342376487234', lat: 56.603728, lon: 16.418273},
      {name: 'Åre strand', hw_id: "3459798234982374", latitude: 63.397163, longitude: 13.074973 },
      {name: 'Gotlands Surfcenter', hw_id: "3482346253486", latitude: 57.483587, longitude: 18.126174}
  ].map! do |s|
    print s[:name]
    puts " "
    Station.find_or_create_by_hw_id(s)
  end
end

puts "\nSeeding stations with random measurements\n"
Station.all.each do |station|
  puts station[:name]
  rnd = Random.new.rand(5..35)
  t = Time.now - (rnd * 1000)
  rnd.times do
    speed = Random.new.rand(0..30)
    measure = station.measures.create({
        station_id: station.id,
        direction: Random.new.rand(0..360),
        speed: speed,
        min_wind_speed: Random.new.rand(0..speed),
        max_wind_speed: Random.new.rand(speed..speed + 15)
    })
    t = t + 1000
    measure.created_at = t
    print "."
  end
  puts "\n"
end