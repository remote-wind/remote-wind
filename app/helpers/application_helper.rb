module ApplicationHelper
  # Renders dynamic page titles
  # @return String
  def title
    if @title.nil?
      "Remote Wind"
    else
      "#{@title} | Remote Wind"
    end
  end
end
