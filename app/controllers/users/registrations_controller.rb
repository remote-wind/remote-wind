# Override verify_authenticity_token to prevent InvalidAuthenticationToken issues when using omniauth
class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, only: [:create, :destroy]
end