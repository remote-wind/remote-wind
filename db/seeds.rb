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


class AdminMaker
  def initialize
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
  end
end

class RandomUsersMaker
  def svenne_generator
    fn = %w[johan nils carl-olof sofie anna kristina sara olof bengt tommy]
    ln1 = %w[berg wall aker holm]
    ln2 = %w[gren kvist strom stedt]

    email =  fn.sample + "." + ln1.sample + ln2.sample + "@example.com"
  end

  def initialize n
    puts "Spawing random users \n"
    n.times do
      print "."
      User.find_or_create_by_email svenne_generator
    end
  end
end


class StationsMaker

  def initialize
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
  end
end

class RandomMeasureMaker
  @speed
  @measures
  @direction
  @ctime

  def initialize n = 50
    puts "Creating #{n} random measures per station"
    @speed = Random.new.rand(5..10)
    @direction = Random.new.rand(0..360)

    Station.all.each do |station|
      puts station[:name] + ": "
      @ctime = (5 * n).minutes.ago

      n.times do
        create_measure( station )
      end
      puts "\n"
    end
  end

  def create_measure station

    # speed variation
    s_var = Random.new.rand(-5..5)

    # Prevent speed from becoming negative
    if @speed + s_var <= 0
      @speed -=  s_var
    else
      @speed += s_var
    end

    # direction variation
    d_var = Random.new.rand(-5..3)

    if @direction + d_var <= 0
      # -- = +
      @direction -=  d_var
    elsif @direction + d_var >= 360
      # -+ = -
      @direction = 0 + d_var
    else
      # plus or minus
      @direction += d_var
    end


    # Prevent speed from becoming negative
    if @speed + s_var <= 0
      @speed -=  s_var
    elsif
      @speed += s_var
    end


    measure = station.measures.create({
      station_id: station.id,
      direction: Random.new.rand(0..360),
      speed: @speed,
      min_wind_speed: @speed - Random.new.rand(0..4),
      max_wind_speed: @speed + Random.new.rand(0..5)
     })
    measure.update_attribute :created_at, @ctime
    measure.update_attribute :updated_at, @ctime

    @ctime += 300
    print "."

    measure.save!
  end
end


admin = AdminMaker.new
users = RandomUsersMaker.new(25)
stations = StationsMaker.new
measures  = RandomMeasureMaker.new(50)