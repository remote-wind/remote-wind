require 'rails_helper'
describe 'observations/index.json.jbuilder', type: :view do

  let(:station) { build_stubbed(:station) }
  let(:observation) { build_stubbed(:observation, created_at: Time.new(2000)) }

  before(:each) do
    render template: 'observations/index.json.jbuilder',
           locals: {
               station: station,
               observations: [observation]
           }
  end

  subject { OpenStruct.new(JSON.parse(rendered).first) }

  #it_should_behave_like "a observation"



end