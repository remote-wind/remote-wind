class Measure < ActiveRecord::Base
  belongs_to :station
  attr_accessor :time_diff
end
