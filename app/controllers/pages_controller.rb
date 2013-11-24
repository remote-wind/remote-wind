class PagesController < ApplicationController

  def home
    @stations = Station.all
  end

  def products

  end
end
