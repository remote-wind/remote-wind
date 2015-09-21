require 'spec_helper'

describe "devise/passwords/new", type: :view do

  before do
    allow(view).to receive(:resource).and_return(User.new)
    allow(view).to receive(:resource_name).and_return(:user)
    allow(view).to receive(:resource_class).and_return(Devise.mappings[:user].to)
    allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
  end

  subject { render; rendered }

  it { is_expected.to have_field "Email" }
  it { is_expected.to have_button "Send" }
end
