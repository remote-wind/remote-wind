#include Geokit::Geocoders

class Station < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                     :lat_column_name => :lat,
                     :lng_column_name => :lon

  has_many :measures
  has_one :current_measure, :class_name => "Measure", :order => 'id desc'
  
end
