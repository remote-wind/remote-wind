# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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