require 'spec_helper'

describe MeasuresController do
  describe 'routing' do

    it 'routes to measures#clear' do
      expect(delete('/stations/1/measures')).to route_to('measures#clear', station_id: '1')
    end

  end
end
