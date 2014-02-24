module ApplicationHelper

  def title
    if @title.nil?
      "Remote Wind"
    else
      "#{@title} | Remote Wind"
    end
  end

end