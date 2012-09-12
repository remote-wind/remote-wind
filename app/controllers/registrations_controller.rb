class RegistrationsController < Devise::RegistrationsController
  load_and_authorize_resource :user, :parent => false
  skip_authorization_check :only => [:create, :new]
  
  def check_permissions
    authorize! :create, resource
  end

end