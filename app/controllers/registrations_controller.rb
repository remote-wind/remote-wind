class RegistrationsController < Devise::RegistrationsController
  skip_authorization_check :only => [:create, :new]  
  def check_permissions
    authorize! :create, resource
  end

end