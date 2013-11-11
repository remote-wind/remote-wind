class Measure < ActiveRecord::Base
  belongs_to :station
  # constraints
  validates_presence_of :station

end