source 'http://rubygems.org'
ruby '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

#= ASSETS ============================================================
gem 'sass-rails', '~> 4.0.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'foundation-rails', :github => 'zurb/foundation-rails'
gem 'compass' # sass toolkit
gem 'rickshaw_rails' # Javascript toolkit for graphs

#= Authentication ====================================================
gem 'devise', '>= 2.2.3'
gem 'cancan'
gem 'rolify', :github => 'EppO/rolify'
gem 'omniauth'
gem 'omniauth-facebook'

#= Geolocation =======================================================
gem 'geocoder' # https://github.com/alexreisner/geocoder
gem 'timezone' # Timezone lookup via lat / lon

#= Misc ===============================================================
gem 'jbuilder', '~> 1.2' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'friendly_id' # Slugging
gem 'nokogiri' # XML/SAX parser.
gem 'will_paginate' #Pagination

#= BDD Tools =========================================================
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'therubyracer', platforms: :ruby # V8 Javascript runtime
  gem 'sqlite3'
  gem 'debugger'
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
  gem 'pg', '0.15.1' # postgres
  gem 'rails_12factor', '0.0.2'
end