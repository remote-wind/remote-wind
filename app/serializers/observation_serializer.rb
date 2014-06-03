# == Schema Information
#
# Table name: observations
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  temperature       :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#
class ObservationSerializer < ActiveModel::Serializer
  attributes :id, :station_id, :speed, :direction, :max_wind_speed, :min_wind_speed, :cardinal

  def attributes
    data = super
    data[:created_at] = object.created_at_local.iso8601
    data[:tstamp] = object.created_at_local.to_i
    data
  end
end
