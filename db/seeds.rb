# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


# Tegefjall 0.3 m/s 183.2° (63.4017,12.97256) IMEI: 354476020409714 all measures
# Mullfjället (63.42258,12.95487) IMEI: 3129831239 all measures
# Ullådalen (63.4321,13.00011) IMEI: 354476020409715 all measures
stations= Station.create([{:name => 'Tegefjall', :hw_id =>'354476020409714', :lat =>'63.4017', :lon =>'12.97256'},
                          {:name => 'Mullfjallet', :hw_id =>'354476020409715', :lat =>'63.42258', :lon =>'12.95487'},
                          {:name => 'Ulladalen', :hw_id =>'354476020409716', :lat =>'63.4321', :lon =>'13.00011'},
                          ])
