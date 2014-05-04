class StationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :name, :slug, :url, :path, :latest_measure

  private

  def url
    station_url(object)
  end

  def path
    station_path(object)
  end

  def latest_measure
    MeasureSerializer.new(object.latest_measure) if object.latest_measure
  end

end
