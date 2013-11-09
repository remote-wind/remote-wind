source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

######## ASSETS ############
gem 'sass-rails', '~> 4.0.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'therubyracer', platforms: :ruby # V8 Javascript runtime
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'turbolinks' # Turbolinks makes following links in your web application faster
gem 'zurb-foundation'  #https://github.com/zurb/foundation-rails

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'sqlite3'
  gem 'debugger'
  gem 'thin'  # use Thin as web server in stead of webbrick
  gem "rspec-rails", ">= 2.12.2"
  gem "database_cleaner", ">= 0.9.1"
  gem "factory_girl_rails", ">= 4.2.0"
  gem "capybara", ">= 2.0.2"
  gem 'guard-rspec', '>=2.5.0', require: false
  gem 'guard-spork'
  gem 'spork-rails', :github => 'sporkrb/spork-rails'
  gem 'terminal-notifier-guard', require: false # OS-X notifications
  gem "fuubar", "~> 1.2.1"
end

# These are for deployment on Heroku
group :production do
  gem 'pg', '0.15.1' # postgres
  gem 'rails_12factor', '0.0.2'
end


