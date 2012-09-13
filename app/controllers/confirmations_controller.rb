class ConfirmationsController < Devise::ConfirmationsController
  skip_authorization_check :only => [:show, :create, :new]
end