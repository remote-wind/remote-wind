require 'spec_helper'

describe "pages/products" do

  subject { render; rendered }

  it "has right breadcrumbs" do
    expect(subject).to have_selector '.breadcrumbs .root', text: 'Home'
    expect(subject).to have_selector '.breadcrumbs .current', text: 'Products'
  end

end