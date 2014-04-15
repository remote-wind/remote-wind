require 'spec_helper'

describe "devise/sessions/new" do

  before do
    view.stub(:resource).and_return(User.new)
    view.stub(:resource_name).and_return(:user)
    view.stub(:resource_class).and_return(Devise.mappings[:user].to)
    view.stub(:devise_mapping).and_return(Devise.mappings[:user])
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