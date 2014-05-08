namespace :scheduler do

  desc "Check if station is reporting regularly and notify owner if it is not"
  task :send_alerts_about_down_stations => :environment do
    Station.check_all_stations
  end

  desc "Check station balance and notify owner if it is low"
  task :send_alerts_about_low_balance_stations => :environment do
    Station.send_low_balance_alerts
  end
end

