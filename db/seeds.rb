# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
class AdminMaker
  def initialize

    attrs = {
        email: ENV["REMOTE_WIND_EMAIL"] || 'admin@example.com',
        password: ENV["REMOTE_WIND_PASSWORD"] || 'password',
        password_confirmation: ENV["REMOTE_WIND_PASSWORD"] || 'password',
        confirmed_at: Time.now
    }

    unless User.find_by(email: attrs[:email])
      admin = User.create_with(attrs).find_or_create_by(email: attrs[:email])
      admin.add_role(:admin)
      puts "Hello my new master #{attrs[:email]}, I have created an account just for you.\n\n"
    end
  end
end

class RandomUsersMaker
  def svenne_generator
    fn = %w[johan nils carl-olof sofie anna kristina sara olof bengt tommy]
    ln1 = %w[berg wall aker holm]
    ln2 = %w[gren kvist strom stedt]

    fn.sample + "." + ln1.sample + ln2.sample + "@example.com"
  end

  def initialize n
    puts "Spawing random users \n"
    n.times do
      print "."
      User.create_with(confirmed_at: Time.now).find_or_create_by(email: svenne_generator)

    end
  end
end

class StationsMaker

  def initialize
    unless Station.any?
      puts "\nCreating stations\n"
      stations = [
          {name: 'Tegefjäll', hw_id: '354476020409714', lat: 63.4017, lon: 12.97256},
          {name: 'Mullfjället', hw_id: '354476020409715', lat: 63.42258, lon: 12.95487},
          {name: 'Ullådalen', hw_id: '354476020409716', lat: 63.4321, lon: 13.00011},
          {name: 'Frösön', hw_id: '3544760204324716', lat: 63.206557, lon: 14.446625},
          {name: 'Näsbokrok', hw_id: '123123123', lat: 57.336714, lon: 12.067055 },
          {name: 'Mörbylånga N', hw_id: '342376487234', lat: 56.603728, lon: 16.418273},
          {name: 'Åre strand', hw_id: "3459798234982374", latitude: 63.397163, longitude: 13.074973 },
          {name: 'Gotlands Surfcenter', hw_id: "3482346253486", latitude: 57.483587, longitude: 18.126174}
      ].map! do |st|
        print st[:name]
        puts " "
        Station.where(hw_id: st[:hw_id]).first_or_create(st) do |station|
          station.status = :unresponsive
        end
      end
    end
  end
end

class RandomObservationMaker
  @speed
  @measures
  @direction
  @ctime

  def initialize n = 50
    puts "Creating #{n} random measures per station \n"

    Station.all.each do |station|
      puts station[:name] + ": "
      @ctime = (n * 5).minutes.ago
      @speed = Random.new.rand(5..10)
      @direction = Random.new.rand(0..360)
      n.times do
        create_measure( station )
      end
      puts "\n"
    end
  end

  def create_measure station

    # speed variation
    s_var = Random.new.rand(-2..2)

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

    measure = Observation.new({
        station: station,
        direction: Random.new.rand(0..360),
        speed: @speed,
        min_wind_speed: @speed - Random.new.rand(0..4),
        max_wind_speed: @speed + Random.new.rand(0..5)
    })

    if measure.save
      measure.update_attribute :created_at, @ctime
      measure.update_attribute :updated_at, @ctime
    end

    @ctime += 300
    print "."

  end
end

class NotificationMaker

  def initialize (n)

    user = User.find_by(email: ENV["REMOTE_WIND_EMAIL"])
    stations = Station.all()

    stations.each do |station|

      puts "Creating random notifications for #{station.name} \n"

      n.times do
        create_notification(user, station)
        print "."
      end

      puts "\n"
    end
  end

  def create_notification user, station

    templates = [
        { message: "Station %s is down.", level: :warn },
        { message: "Station %s is up.", level: :info }
    ]

    template = templates.sample.merge!({ user: user })
    template[:message] =  template[:message] % [station.name]

    note = Notification.new( template )

    if note.save
      note.update_attribute(:created_at, Time.at(rand_in_range(30.days.ago.to_f, Time.now.to_f)))
    end
  end

  def rand_in_range(from, to)
    rand * (to - from) + from
  end

end


AdminMaker.new
RandomUsersMaker.new(25)
StationsMaker.new
RandomObservationMaker.new(50)
NotificationMaker.new(5)
