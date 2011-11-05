# Be sure to restart your server when you modify this file.
#
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.


# Disable root element in JSON by default.
if defined?(ActiveRecord)
  ActiveRecord::Base.include_root_in_json = false
end