# Emits observations as JSON
class ObservationSerializer < ActiveModel::Serializer
  attributes :id, :station_id, :speed, :direction, :max_wind_speed, :min_wind_speed, :cardinal

  def attributes
    data = super
    data[:created_at] = object.created_at.iso8601
    data[:tstamp] = object.created_at_local.to_i
    data
  end
end
