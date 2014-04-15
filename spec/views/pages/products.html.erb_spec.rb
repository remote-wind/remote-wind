require 'spec_helper'

describe "pages/products" do

  let! (:rendered_view) do
    render
    rendered
  end

  it "has the correct contents" do
    expect(rendered_view).to have_selector '.breadcrumbs .root', text: 'Home'
    expect(rendered_view).to have_selector '.breadcrumbs .current', text: 'Products'
  end

end