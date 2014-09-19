class StationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :name, :slug, :url, :path, :offline, :observations

  has_many :observations

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

end
