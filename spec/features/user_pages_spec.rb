feature 'user pages' do

  let!(:user) { create(:user) }
  let!(:admin) do
    admin = create(:admin)
    sign_in_as admin.email, admin.password
    admin
  end

  scenario 'when visiting index' do
    visit users_path
    expect(page).to have_content user.email
  end

  scenario 'when clicking user on index' do
    visit users_path
    click_link user.email
    expect(current_path).to eq user_path(user)
    expect(page).to have_content user.email
  end

end