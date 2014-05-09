source 'http://rubygems.org'
ruby '2.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.1'

#= ASSETS ============================================================
gem 'sass-rails', '~> 4.0.3' # Use SCSS for stylesheets
gem 'uglifier', '~> 2.5.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'jquery-rails', '~> 3.1.0' # Use jquery as the JavaScript library
gem 'foundation-rails', github: 'zurb/foundation-rails'
gem 'rickshaw_rails', '~> 1.4.5' # Javascript toolkit for graphs

#= Authentication ====================================================
gem 'devise', '~> 3.2.4'
gem 'devise_invitable', '~> 1.3.5'
gem 'cancan', '~> 1.6.10'
gem 'rolify', github: 'EppO/rolify'
gem 'omniauth', '~> 1.2.1'
gem 'omniauth-facebook', '~> 1.6.0'

#= Geolocation =======================================================
gem 'geocoder', '~> 1.2.0' # https://github.com/alexreisner/geocoder
gem 'timezone', '~> 0.3.2' # Timezone lookup via lat / lon

#= Misc ===============================================================
gem 'jbuilder', '~> 1.2' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'friendly_id', '~> 5.0.3' # Slugging
gem 'nokogiri', '~> 1.6.1' # XML/SAX parser.
gem 'will_paginate', '~> 3.0.5' #Pagination
gem 'cache_digests', '~> 0.3.1' #Cache invalidation
gem 'active_model_serializers', '~> 0.8.1' # object serialization

#= BDD Tools =========================================================
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem "dotenv-rails", "~> 0.10.0" # load local config from .env file
  gem 'therubyracer', platforms: :ruby # V8 Javascript runtime
  gem 'thin'  # use Thin as web server instead of webbrick
  gem 'zeus', '0.13.4.pre2', require: false # Zeus is a process forker that quickstarts rSpec and server
end

group :development do
  gem 'guard-livereload', require: false
  gem 'better_errors' # better error pages
  gem 'binding_of_caller' # REPL on error pages
  gem 'meta_request' # used for RailsPanel in Google Chrome
end

group :test do
  gem 'rspec-rails', '>=1.14'
  gem 'database_cleaner' # cleans test database between specs
  gem 'factory_girl_rails' # Replaces fixtures with object factories
  gem 'shoulda-matchers' # Matchers for common ActiveRecord patterns.
  gem 'simplecov', :require => false # Used to generate test coverage reports
  gem 'guard-rspec', '>=2.5.0', require: false # Continuus testing tool
  gem 'capybara' # Web crawler
  gem 'guard-zeus', require: false # Use guard with zeus
end

#= Heroku Dependencies =========================================================
group :production do
  gem 'pg', '~> 0.17.1' # postgres
  gem 'rails_12factor', '0.0.2'
end