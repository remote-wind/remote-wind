class RegistrationsController < Devise::RegistrationsController
  authorize_resource :user
  skip_authorization_check :only => [:create, :new]  
end