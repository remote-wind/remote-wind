class SessionsController < Devise::SessionsController
  skip_authorization_check :only => [:new, :create, :destroy]
end