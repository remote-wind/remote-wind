# == Schema Information
#
# Table name: measures
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#
require 'spec_helper'

describe MeasureSerializer do

  let(:attributes) { attributes_for(:measure, created_at: Time.new(2000)) }
  it_behaves_like 'a measure'

end