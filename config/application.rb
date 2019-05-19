require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RemoteWind
  class Application < Rails::Application
    # By default, Rails expects app/services/users/delete.rb to define Users::Delete,
    # but we want it to expect Services::Users::Delete.
    # To make this work, we add the app folder to the autoload path
    # @see https://github.com/krautcomputing/services
    config.autoload_paths += [config.root.join('app')]
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    # Test suite setup
    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
