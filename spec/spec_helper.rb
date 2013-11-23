def zeus_running?
  File.exists? '.zeus.sock'
end


if !zeus_running?
  require 'simplecov'
  SimpleCov.start "rails" do
    add_filter do |source_file|
      source_file.lines.count < 5
    end
  end
end

# Code run before forking in spork / zeus
prefork = lambda do

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'webmock/rspec'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = 'random'

    # clean database before running tests
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end
    config.before(:each) do
      DatabaseCleaner.start
    end
    config.after(:each) do
      DatabaseCleaner.clean
    end

    include FactoryGirl::Syntax::Methods
    include Devise::TestHelpers
    include Warden::Test::Helpers
    include Features::SessionHelpers

    config.before(:each) do
      Station.any_instance.stub(:lookup_timezone).and_return("London")
    end

    OmniAuth.config.test_mode = true
    Warden.test_mode!

  end
end
# This code will be run each time you run your specs.
each_run = lambda do

end

if defined?(Zeus)
  prefork.call
  $each_run = each_run
  class << Zeus.plan
    def after_fork_with_test
      after_fork_without_test
      $each_run.call
    end
    alias_method_chain :after_fork, :test
  end
elsif ENV['spork'] || $0 =~ /\bspork$/
  require 'spork'
  Spork.prefork(&prefork)
  Spork.each_run(&each_run)
else
  prefork.call
  each_run.call
end