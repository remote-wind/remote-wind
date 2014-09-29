require 'spec_helper'

describe StationSerializer do
  include Rails.application.routes.url_helpers
  let!(:resource) { build_stubbed(:station, slug: 'foo', offline: true) }
  it_behaves_like 'a station'
end