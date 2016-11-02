require 'rails_helper'

feature "products page" do
  scenario "when I am at home page and want to check out products" do
    visit root_path
    click_link "Products"
    expect(current_path).to eq products_path
    expect(page).to have_title "Products | Remote Wind"
  end
end