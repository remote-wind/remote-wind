require 'spec_helper'

describe "pages/products" do

  subject {
    render
    rendered
  }

  it { should have_selector '.breadcrumbs .root', text: 'Home' }
  it { should have_selector '.breadcrumbs .current', text: 'Products' }

end