namespace :staging do
  desc 'Tasks for adapting live data to staging server'

  task cull: :environment do
    puts "Removing measures older than #{2.days.ago}"
    old_measures = Measure.where('created_at < ?', 2.days.ago)
    puts "#{old_measures.destroy_all} rows affected"
  end
end