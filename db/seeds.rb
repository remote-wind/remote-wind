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

admin = User.new
admin.email = ENV["REMOTE_WIND_EMAIL"]
admin.password = ENV["REMOTE_WIND_PASSWORD"]
admin.password_confirmation = ENV["REMOTE_WIND_PASSWORD"]
admin.add_role(:admin)
admin.save!

users = %w[joe.smoe@example.com john.doe@example.com test@example.com]

users.each do |email|
  user = User.new
  user.email = email
  user.password = 'kitekite'
  user.password_confirmation = 'kitekite'
  user.save!
end

# Tegefjall 0.3 m/s 183.2° (63.4017,12.97256) IMEI: 354476020409714 all measures
# Mullfjället (63.42258,12.95487) IMEI: 3129831239 all measures
# Ullådalen (63.4321,13.00011) IMEI: 354476020409715 all measures
stations= Station.create([{:name => 'Tegefjäll', :hw_id =>'354476020409714', :lat =>'63.4017', :lon =>'12.97256', :user => User.find_by_email(ENV["REMOTE_WIND_EMAIL"])},
                          {:name => 'Mullfjället', :hw_id =>'354476020409715', :lat =>'63.42258', :lon =>'12.95487'},
                          {:name => 'Ullådalen', :hw_id =>'354476020409716', :lat =>'63.4321', :lon =>'13.00011'},
                         ])

stations.each do |station|

  rand(1..15).times do

    station.measures.create(
        :speed => rand(0..40),
        :direction => rand(0..360),
        :max_wind_speed => rand(0..40),
        :min_wind_speed => rand(0..40)
    )
  end

end