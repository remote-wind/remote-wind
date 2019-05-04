# Emits observations as JSON
class StationSerializer < ActiveModel::Serializer
  attributes  :id, :latitude, :longitude, :name, :slug, :path,
              :status, :latest_observation
  private

    def path
      station_path(object)
    end
end
