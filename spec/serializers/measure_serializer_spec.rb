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
  its(:id)              { should eq attributes[:id] }
  its(:station_id)      { should eq attributes[:station_id] }
  its(:speed)           { should eq attributes[:speed] }
  its(:direction)       { should eq attributes[:direction] }
  its(:max_wind_speed)  { should eq attributes[:max_wind_speed] }
  its(:min_wind_speed)  { should eq attributes[:min_wind_speed] }
  its(:created_at)      { should eq Time.new(2000).iso8601 }
  its(:tstamp)          { should eq Time.new(2000).to_i }

end