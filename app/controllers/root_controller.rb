class RootController < ApplicationController
  skip_authorization_check :only => [:index]  
  
  def index
    @stations = Station.all

    respond_to do |format|
      format.html
    end
  end
  
end
