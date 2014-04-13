feature 'user pages' do

  let(:user) { create(:user, nickname: 'foo') }
  before(:each) { login user }

  scenario 'when visiting index' do
    visit users_path
    expect(page).to have_content user.email
    expect(page).to have_title "Users | Remote Wind"
  end

  scenario 'when clicking user on index' do
    visit users_path
    click_link user.email
    expect(page).to have_title "foo | Remote Wind"
    expect(current_path).to eq user_path(user)
    expect(page).to have_content user.email
  end

  scenario 'when I enter friendly url' do
    visit '/users/foo'
    expect(page).to have_title 'foo | Remote Wind'
  end

end