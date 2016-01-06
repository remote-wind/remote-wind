require 'spec_helper'

describe ObservationsController, type: :routing do
  describe 'routing' do

    it 'routes to observations#clear' do
      expect(delete('/stations/1/observations')).to route_to('observations#clear', station_id: '1')
    end

  end
end
