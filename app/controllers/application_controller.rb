class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization # enforce CanCan authorization on all methods
end
