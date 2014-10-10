class StationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :name, :slug, :url, :path, :offline, :observations
  private

  # Prevents memory issues if observations have not been preloaded
  def observations
    if object.observations.loaded?
      object.observations
    else
      object.load_observations!(10)
    end
  end

  def offline
    object.offline?
  end

  def url
    station_url(object)
  end

  def path
    station_path(object)
  end
end