class PasswordsController < Devise::PasswordsController
  skip_authorization_check :only => [:new, :create]
end