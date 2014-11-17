require 'benchmark'

namespace :scheduler do

  desc "Check if station is reporting regularly and notify owner if it is not"
  task :send_alerts_about_down_stations => :environment do |t|
   bm = Benchmark.bm do |x|
      x.report { Station.check_all_stations }
   end
   Rails.logger.info("Ran rake:#{t.name} in #{bm.first.total} seconds")
  end

  desc "Check station balance and notify owner if it is low"
  task :send_alerts_about_low_balance_stations => :environment do |t|
    bm = Benchmark.bm do |x|
      x.report("check_all_stations") { Station.send_low_balance_alerts }
    end
    Rails.logger.info("Ran rake:#{t.name} in #{bm.first.total} seconds")
  end
end