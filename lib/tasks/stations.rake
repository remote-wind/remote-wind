namespace :stations do
  desc "Import stations"
  task :import => :environment do
    require 'securerandom'
    stations = [
    	{ name: "TRV Nynashamn",   latitude: 17.92341,   longitude: 58.9343872 },
    	{ name: "TRV Borgholm",  latitude: 16.73219,  longitude: 56.88985 },
    	{ name: "TRV Klintehamn",  latitude: 18.1841087,  longitude: 57.4022064 },
    	{ name: "TRV Näs",  latitude: 18.2801781,  longitude: 57.1313 },
    	{ name: "TRV Albrunna",  latitude: 16.4066257,  longitude: 56.32067 },
    	{ name: "TRV Sandby",  latitude: 16.6184483,  longitude: 56.5693436 },
    	{ name: "TRV Ölandsbron",  latitude: 16.3876362,  longitude: 56.6803741 },
    	{ name: "TRV Mocklösund",  latitude: 15.7429752,  longitude: 56.13716 },
    	{ name: "TRV Östergarn",  latitude: 18.8206844,  longitude: 57.428318 },
    	{ name: "TRV Båstad v",  latitude: 12.7268848,  longitude: 56.4340324 },
    	{ name: "TRV Smygehamn",  latitude: 13.3558693,  longitude: 55.3389931 },
    	{ name: "TRV Loddekopinge",  latitude: 13.0153866,  longitude: 55.74928 },
    	{ name: "TRV Örnahusen",  latitude: 14.2562866,  longitude: 55.4482 },
    	{ name: "TRV Åhus",  latitude: 14.2699652,  longitude: 55.9133644 },
    	{ name: "TRV Landskrona s",  latitude: 12.8885012,  longitude: 55.8577 },
    	{ name: "TRV Lernacken",  latitude: 12.8947182,  longitude: 55.5653152 },
    	{ name: "TRV Nygard",  latitude: 12.289094,  longitude: 57.0714531 },
    	{ name: "TRV Brotorpet",  latitude: 12.7020369,  longitude: 56.724308 },
    	{ name: "TRV Bokenäs",  latitude: 11.5640793,  longitude: 58.29175 },
    	{ name: "TRV Halmstad",  latitude: 12.904788,  longitude: 56.6367073 },
    	{ name: "TRV Mariedal",  latitude: 11.9815979,  longitude: 57.40679 },
    	{ name: "TRV Fiskeback",  latitude: 11.8635559,  longitude: 57.64441 }
    ]

    stations.each do |hash|
    	s = Station.find_or_initialize_by(hash) do |s|
    		s.user_id = 				2 # karl-petter
    		s.description = 		"Väderstation som opereras av Trafikverket."
    		s.hw_id =						SecureRandom.uuid # just a random uuid
    		s.sampling_rate = 	3600 # 1 hour
    	end
      if s.new_record?
        s.save!
        puts "#{s.name} created."
      else
        puts "#{s.name} already exists."
      end
    end
  end
end
