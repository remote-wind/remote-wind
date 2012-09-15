class InvitationsController < Devise::InvitationsController
  load_and_authorize_resource :user, :parent => false
  skip_authorization_check :only => [:accept]
  def new
    if cannot?( :invite, User )
      raise CanCan::AccessDenied
    else
      super
    end
  end
  
  def create
    if cannot?( :invite, User )
      raise CanCan::AccessDenied
    else
      super
    end
  end
end