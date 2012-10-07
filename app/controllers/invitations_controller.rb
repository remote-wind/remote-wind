class InvitationsController < Devise::InvitationsController
  skip_authorization_check :only => [:accept, :edit, :update]
  def new
    if cannot?( :invite, User )
      raise CanCan::AccessDenied
    else
      super
    end
  end
  
  def update
    zone = ActiveSupport::TimeZone.create("CET")
    Time.zone = zone unless zone.nil?
    super
  end
  
  def create
    if cannot?( :invite, User )
      raise CanCan::AccessDenied
    else
      super
    end
  end
end