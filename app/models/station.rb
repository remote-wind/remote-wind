class Station < ActiveRecord::Base
  has_many :measures
  acts_as_mappable  :lat_column_name => :lat,
                    :lng_column_name => :lon
end
