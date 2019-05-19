# Handles relativly static pages
class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @stations = @all_stations
  end

  def products
    @title = "Products"
  end
end
