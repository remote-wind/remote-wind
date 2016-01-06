require 'spec_helper'

describe "devise/sessions/new", type: :view do

  before do
    allow(view).to receive(:resource).and_return(User.new)
    allow(view).to receive(:resource_name).and_return(:user)
    allow(view).to receive(:resource_class).and_return(Devise.mappings[:user].to)
    allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
  end

  let(:page) do
    render
    rendered
  end

  it "has the correct contents" do
    expect(page).to have_link "Sign in with Facebook"
    expect(page).to have_field "Email"
    expect(page).to have_field "Password"
  end
  

end