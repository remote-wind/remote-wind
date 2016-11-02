source 'http://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.4'
gem 'puma'

#= ASSETS ============================================================
gem 'sass-rails', '~> 4.0.3' # Use SCSS for stylesheets
gem 'uglifier', '~> 2.5.0' # Use Uglifier as compressor for JavaScript assets
gem 'jquery-rails', '~> 3.1.0' # Use jquery as the JavaScript library
gem 'foundation-rails', '~> 5.4.5.0' # Responsive front-end framework
gem 'rickshaw_rails', '~> 1.4.5' # Javascript toolkit for graphs

#= Views  ============================================================
gem 'simple_form', '~> 3.1.1' # Forms made easy for Rails!: https://github.com/plataformatec/simple_form

#= Authentication ====================================================
gem 'devise', '~> 3.5.2'
gem 'devise_invitable', '~> 1.3.5'
gem 'cancancan', '~> 1.12.0'
gem 'rolify', '~> 4.1.1'
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-facebook', '~> 2.0.1'

#= Geolocation =======================================================
gem 'geocoder', '~> 1.2.11' # https://github.com/alexreisner/geocoder
gem 'timezone', '~> 1.2', '>= 1.2.2' # Timezone lookup via lat / lon

#= Misc ===============================================================
gem 'friendly_id', '~> 5.1.0' # Slugging
gem 'will_paginate', '~> 3.0.7' #Pagination
gem 'active_model_serializers', '~> 0.9.3' # object serialization

#= Email ===============================================================
gem 'markerb', '~> 1.0.2' # Multipart templates made easy with Markdown + ERb: https://github.com/plataformatec/markerb
gem 'kramdown', '~> 1.4.1' # Markdown parser

gem 'minitest'

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
  gem 'foreman' # launches server from procfile
  gem 'terminal-notifier', require: false
  # Show test status indicators on Mac OS X
  gem "terminal-notifier-guard", require: false
  gem 'launchy', require: false
end

group :development do
  gem 'better_errors' # better error pages
  gem 'binding_of_caller' # REPL on error pages
  gem 'meta_request' # used for RailsPanel in Google Chrome
end

group :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'database_cleaner' # cleans test database between specs
  # factory_girl provides a framework and DSL for defining and using factories.
  gem "factory_girl_rails", "~> 4.7"
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
