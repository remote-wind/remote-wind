# Emits observations as JSON
class StationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :name, :slug, :path, :offline, :observations
  private
    # Prevents memory issues if observations have not been preloaded
    # @todo CLEANUP is this still neeeded?
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

    def path
      station_path(object)
    end
end
