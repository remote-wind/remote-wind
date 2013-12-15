desc "This task is called by the Heroku scheduler add-on"
task :send_alerts_about_down_stations => :environment do
  Station.send_down_alerts
end

task :send_alerts_about_low_balance_stations => :environment do
  Station.send_low_balance_alerts
end