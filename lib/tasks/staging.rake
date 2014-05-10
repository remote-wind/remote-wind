namespace :staging do
  desc 'Tasks for adapting live data to staging server'

  task cull: :environment do
    puts "Removing observations older than #{2.days.ago}"
    old_observations = Observation.where('created_at < ?', 2.days.ago)
    puts "#{old_observations.destroy_all} rows affected"
  end
end