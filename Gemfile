source 'http://rubygems.org'
ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'
gem 'puma'

#= ASSETS ============================================================
gem 'sassc-rails', '~> 2.1', '>= 2.1.1'# Use SCSS for stylesheets
gem 'jquery-rails', '~> 4.3', '>= 4.3.3' # Use jquery as the JavaScript library
gem 'foundation-rails', '~> 5.4.5.0' # Responsive front-end framework
gem 'rickshaw_rails', '~> 1.4.5' # Javascript toolkit for graphs

#= Views  ============================================================
gem 'simple_form', '~> 3.5.1' # Forms made easy for Rails!: https://github.com/plataformatec/simple_form

#= Authentication ====================================================
gem 'devise', '~> 4.6', '>= 4.6.2'
gem 'devise_invitable', '~> 1.7'
gem 'rolify', '~> 5.1.0'
gem 'pundit', '~> 1.1'

#= Geolocation =======================================================
gem 'geocoder', '~> 1.2.11' # https://github.com/alexreisner/geocoder

#= Misc ===============================================================
gem 'friendly_id', '~> 5.1.0' # Slugging
gem 'will_paginate', '~> 3.0.7' #Pagination
gem 'active_model_serializers', '~> 0.9.3' # object serialization

#= Email ===============================================================
gem 'markerb', '~> 1.0.2' # Multipart templates made easy with Markdown + ERb: https://github.com/plataformatec/markerb
gem 'kramdown', '~> 1.4.1' # Markdown parser

gem 'minitest'

gem 'newrelic_rpm'

#= BDD Tools =========================================================
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'yard'
end

group :development, :test do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem "dotenv-rails"  # load local config from .env file
  gem 'ffaker'
  gem 'terminal-notifier', require: false
  # Show test status indicators on Mac OS X
  gem "terminal-notifier-guard", require: false
  gem 'launchy', require: false
  gem 'byebug' # byebug debugger
end

group :development do
  gem 'meta_request' # used for RailsPanel in Google Chrome
end

group :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'database_cleaner' # cleans test database between specs
  # factory_girl provides a framework and DSL for defining and using factories.
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  # Matchers to make model specs easy on the fingers and eyes
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem "rspec-its"
  # Capybara is an integration testing tool for rack based web applications.
  gem 'capybara', '~> 2.10', '>= 2.10.1'
  gem 'guard-rspec', '~> 4.7', '>= 4.7.3'
  gem 'timecop'
end

#= Heroku Dependencies =========================================================
group :production do
  gem 'pg', '~> 0.18.3' # postgres
  gem 'rails_12factor', '0.0.2'
end
