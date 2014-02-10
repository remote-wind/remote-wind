module ApplicationHelper
  def cache_if(condition, name = {}, &block)
    if condition
      cache(name, &block)
    else
      yield
    end
  end

  def cache_unless(condition, name = {}, &block)
    unless condition
      cache(name, &block)
    else
      yield
    end
  end

end