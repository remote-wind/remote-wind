#include Geokit::Geocoders
class Station < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                     :lat_column_name => :lat,
                     :lng_column_name => :lon

  belongs_to :user
  has_many :measures, :dependent => :destroy
  has_one :current_measure, :class_name => "Measure", :order => 'id desc'
  
  # arduino client has not memory enough to post the station name so it cannot be required!
  validates :hw_id, :presence => true # must have a hw_id
  validates :hw_id, :uniqueness => true # and the hw_id must be unique
  
end
