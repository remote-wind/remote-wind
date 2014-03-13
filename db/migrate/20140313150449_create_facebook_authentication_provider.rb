class CreateFacebookAuthenticationProvider < ActiveRecord::Migration
  def up
    AuthenticationProvider.find_or_create_by(name: 'facebook')
  end
  def down
    AuthenticationProvider.find_by(name: 'facebook').destroy
  end
end
