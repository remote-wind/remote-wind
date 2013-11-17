module PagesHelper
  def is_home?
    params[:controller] == 'pages' && params[:action] == 'home'
  end
end