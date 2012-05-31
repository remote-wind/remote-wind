Time::DATE_FORMATS[:myDateTimeFormat] = "%Y-%m-%d %H:%M:%S"

# datetime.to_formatted_s(:db)            # => "2007-12-04 00:00:00"
# datetime.to_s(:db)                      # => "2007-12-04 00:00:00"
# datetime.to_s(:number)                  # => "20071204000000"
# datetime.to_formatted_s(:short)         # => "04 Dec 00:00"
# datetime.to_formatted_s(:long)          # => "December 04, 2007 00:00"
# datetime.to_formatted_s(:long_ordinal)  # => "December 4th, 2007 00:00"
# datetime.to_formatted_s(:rfc822)        # => "Tue, 04 Dec 2007 00:00:00 +0000"
# 
# :db => "%Y-%m-%d %H:%M:%S", 
# :number => "%Y%m%d%H%M%S", 
# :time => "%H:%M", 
# :short => "%d %b %H:%M", 
# :long => "%B %d, %Y %H:%M", 
# :long_ordinal => lambda { |time| time.strftime("%B #{ActiveSupport::Inflector.ordinalize(time.day)}, %Y %H:%M") }, 
# :rfc822 => lambda { |time| time.strftime("%a, %d %b %Y %H:%M:%S #{time.formatted_offset(false)}") } }