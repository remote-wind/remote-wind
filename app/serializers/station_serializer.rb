class StationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :name, :slug, :url, :path, :latest_observation, :offline

  private

  def offline
    object.offline?
  end

  def url
    station_url(object)
  end

  def path
    station_path(object)
  end

  def latest_observation
    ObservationSerializer.new(object.latest_observation) if object.latest_observation
  end

end
